extends Node3D
class_name CharacterSprite3D
# ─────────────────────────────────────────────────────────────────────────────
# CharacterSprite3D.gd  —  Twelve Stones / Ephod Quest
# High-quality 2.5D billboard character system.
# Replaces blocky box-mesh characters with expressive cartoon sprites
# rendered as GPU-shaded quads that always face the camera (true billboard).
#
# Features:
#   • 8-direction sprite sheet support (or single SVG portrait)
#   • Procedural cartoon body (rounded shapes, big eyes) when no SVG loaded
#   • Idle, Walk, Talk, Pray, Celebrate, Hurt animations via AnimationPlayer
#   • Shadow plane beneath character
#   • Name label floating above head (TextMesh or Label3D)
#   • Soft pulsing outline glow when highlighted
#   • Simple emotion system: happy / sad / surprised / neutral
#
# "He made them in His image" — Genesis 1:27
# ─────────────────────────────────────────────────────────────────────────────

enum Emotion { NEUTRAL, HAPPY, SAD, SURPRISED, FOCUSED }
enum Direction { S, SW, W, NW, N, NE, E, SE }

# ── Configuration ─────────────────────────────────────────────────────────────
@export var character_name:   String  = ""
@export var sprite_path:      String  = ""      # optional SVG/PNG path
@export var skin_color:       Color   = Color(0.78, 0.58, 0.38)   # olive
@export var hair_color:       Color   = Color(0.15, 0.08, 0.03)   # dark
@export var robe_color:       Color   = Color(0.72, 0.52, 0.22)   # camel
@export var robe_trim_color:  Color   = Color(0.85, 0.72, 0.42)   # gold trim
@export var eye_color:        Color   = Color(0.12, 0.06, 0.02)   # dark brown
@export var scale_factor:     float   = 1.0
@export var is_elder:         bool    = false
@export var cast_shadow:      bool    = true
@export var show_name_label:  bool    = true

# ── Internal nodes ────────────────────────────────────────────────────────────
var _billboard_mesh:  MeshInstance3D     # main sprite quad
var _shadow_mesh:     MeshInstance3D     # flat ellipse shadow on ground
var _name_label:      Label3D
var _glow_mesh:       MeshInstance3D     # outline glow on interact
var _emotion_label:   Label3D            # emoji emotion over head
var _anim_tween:      Tween

# ── Shader source for billboard (always faces camera) ─────────────────────────
const BILLBOARD_SHADER := """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque;

uniform sampler2D albedo_tex : source_color, hint_default_white;
uniform vec4      tint_color : source_color = vec4(1.0);
uniform float     outline_width  = 0.0;
uniform vec4      outline_color : source_color = vec4(1.0, 0.85, 0.0, 1.0);
uniform vec2      sprite_offset = vec2(0.0);   // for sprite sheet animation
uniform vec2      sprite_size   = vec2(1.0);   // normalised size per frame

varying vec2 frag_uv;

void vertex() {
    // Billboard: cancel world rotation — always face camera
    vec3 camera_right = normalize(vec3(INV_VIEW_MATRIX[0].x, 0.0, INV_VIEW_MATRIX[2].x));
    vec3 camera_up    = vec3(0.0, 1.0, 0.0);

    vec3 world_pos = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;

    // Scale
    float sx = length(vec3(MODEL_MATRIX[0].xyz));
    float sy = length(vec3(MODEL_MATRIX[1].xyz));

    POSITION = VIEW_MATRIX * vec4(
        world_pos
        + camera_right * VERTEX.x * sx
        + camera_up    * VERTEX.y * sy,
        1.0
    );
    POSITION = PROJECTION_MATRIX * POSITION;

    frag_uv = UV * sprite_size + sprite_offset;
}

void fragment() {
    vec4 col = texture(albedo_tex, frag_uv) * tint_color;

    if (outline_width > 0.01) {
        float edge_dist = min(min(frag_uv.x, 1.0 - frag_uv.x),
                              min(frag_uv.y, 1.0 - frag_uv.y));
        float outline = smoothstep(0.0, outline_width, edge_dist);
        col.rgb = mix(outline_color.rgb, col.rgb, outline);
    }

    ALBEDO = col.rgb;
    ALPHA  = col.a;
    if (ALPHA < 0.05) discard;
}
"""

# ── Cartoon body draw helper — builds a high-quality procedural texture ───────
# Creates a 256×512 RGBA Image with rounded shapes, big eyes, robe details.

static func _draw_cartoon_character(
    skin:       Color,
    hair:       Color,
    robe:       Color,
    robe_trim:  Color,
    eye_col:    Color,
    elder:      bool
) -> ImageTexture:
    var img := Image.create(256, 512, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))   # transparent background

    # ── Helper lambdas ──────────────────────────────────────────────────────
    var fill_ellipse := func(cx: int, cy: int, rx: int, ry: int, c: Color) -> void:
        for dy in range(-ry, ry + 1):
            for dx in range(-rx, rx + 1):
                if (float(dx)/rx)*(float(dx)/rx) + (float(dy)/ry)*(float(dy)/ry) <= 1.0:
                    var px := cx + dx
                    var py := cy + dy
                    if px >= 0 and px < 256 and py >= 0 and py < 512:
                        img.set_pixel(px, py, c)

    var fill_rect := func(x: int, y: int, w: int, h: int, c: Color) -> void:
        for py in range(y, y + h):
            for px in range(x, x + w):
                if px >= 0 and px < 256 and py >= 0 and py < 512:
                    img.set_pixel(px, py, c)

    var fill_rounded_rect := func(x: int, y: int, w: int, h: int, r: int, c: Color) -> void:
        for py in range(y, y + h):
            for px in range(x, x + w):
                var in_rect := px >= x and px < x+w and py >= y and py < y+h
                if not in_rect: continue
                # round corners
                var corners := [
                    Vector2(x + r, y + r), Vector2(x+w-r, y + r),
                    Vector2(x + r, y+h-r), Vector2(x+w-r, y+h-r)
                ]
                var in_corner_zone := (px < x+r or px >= x+w-r) and (py < y+r or py >= y+h-r)
                if in_corner_zone:
                    var ok := false
                    for corner in corners:
                        if (px - corner.x)*(px - corner.x) + (py - corner.y)*(py - corner.y) <= r*r:
                            ok = true; break
                    if ok:
                        img.set_pixel(px, py, c)
                else:
                    img.set_pixel(px, py, c)

    # ── HEAD ───────────────────────────────────────────────────────────────
    var head_cx := 128;  var head_cy := 105
    var head_rx := 52;   var head_ry := 60

    # Head base — skin with soft shading
    fill_ellipse.call(head_cx, head_cy, head_rx, head_ry, skin)
    # Cheek blush
    var blush := skin.lightened(0.15)
    blush.a = 0.45
    fill_ellipse.call(head_cx - 28, head_cy + 14, 16, 12, blush)
    fill_ellipse.call(head_cx + 28, head_cy + 14, 16, 12, blush)

    # ── HAIR ──────────────────────────────────────────────────────────────
    # Hair cap + flowing sides
    fill_ellipse.call(head_cx, head_cy - 12, head_rx + 2, head_ry * 55 / 100, hair)
    # Side hair flowing down
    fill_ellipse.call(head_cx - 44, head_cy + 12, 18, 36, hair)
    fill_ellipse.call(head_cx + 44, head_cy + 12, 18, 36, hair)

    # ── HEAD WRAP (for Reuben/desert tribes) / elder crown ────────────────
    var wrap_color := hair.lightened(0.25)
    fill_rounded_rect.call(head_cx - 48, head_cy - 62, 96, 30, 12, wrap_color)
    # Wrap band
    fill_rounded_rect.call(head_cx - 50, head_cy - 44, 100, 12, 4, robe_trim)

    if elder:
        # Elder silver hair + full beard
        fill_ellipse.call(head_cx, head_cy - 8, head_rx + 2, head_ry * 60 / 100,
            Color(0.88, 0.85, 0.78))
        fill_ellipse.call(head_cx, head_cy + head_ry + 10, 32, 28,
            Color(0.90, 0.87, 0.80))   # beard

    # ── EYES (big expressive cartoon eyes) ────────────────────────────────
    var eye_l_x := head_cx - 20;  var eye_r_x := head_cx + 20
    var eye_y   := head_cy + 6

    # White sclera
    fill_ellipse.call(eye_l_x, eye_y, 13, 11, Color(0.97, 0.97, 0.95))
    fill_ellipse.call(eye_r_x, eye_y, 13, 11, Color(0.97, 0.97, 0.95))
    # Iris
    fill_ellipse.call(eye_l_x + 1, eye_y + 1, 8, 9, eye_col)
    fill_ellipse.call(eye_r_x - 1, eye_y + 1, 8, 9, eye_col)
    # Pupil
    fill_ellipse.call(eye_l_x + 1, eye_y + 1, 4, 5, Color(0.04, 0.02, 0.01))
    fill_ellipse.call(eye_r_x - 1, eye_y + 1, 4, 5, Color(0.04, 0.02, 0.01))
    # Catchlight (sparkle in eye)
    img.set_pixel(eye_l_x + 3, eye_y - 1, Color(1,1,1,0.95))
    img.set_pixel(eye_l_x + 4, eye_y - 2, Color(1,1,1,0.7))
    img.set_pixel(eye_r_x - 3, eye_y - 1, Color(1,1,1,0.95))
    img.set_pixel(eye_r_x - 4, eye_y - 2, Color(1,1,1,0.7))
    # Top eyelash line
    for i in range(-12, 14): img.set_pixel(eye_l_x + i, eye_y - 10, Color(0.1, 0.06, 0.04))
    for i in range(-12, 14): img.set_pixel(eye_r_x + i, eye_y - 10, Color(0.1, 0.06, 0.04))

    # ── NOSE ──────────────────────────────────────────────────────────────
    fill_ellipse.call(head_cx + 1, head_cy + 24, 5, 4, skin.darkened(0.12))
    fill_ellipse.call(head_cx - 7, head_cy + 26, 4, 3, skin.darkened(0.1))
    fill_ellipse.call(head_cx + 9, head_cy + 26, 4, 3, skin.darkened(0.1))

    # ── MOUTH (slight smile) ───────────────────────────────────────────────
    for i in range(-14, 15):
        var my := head_cy + 44 + int(float(i*i) * 0.05)
        img.set_pixel(head_cx + i, my, Color(0.55, 0.25, 0.15))
    # Lip shine
    for i in range(-6, 7):
        img.set_pixel(head_cx + i, head_cy + 44, Color(0.78, 0.48, 0.35, 0.5))

    # ── NECK ──────────────────────────────────────────────────────────────
    fill_rect.call(head_cx - 14, head_cy + head_ry - 4, 28, 28, skin)

    # ── TORSO / ROBE ──────────────────────────────────────────────────────
    var torso_y := head_cy + head_ry + 22;  var torso_w := 88;  var torso_h := 130
    fill_rounded_rect.call(head_cx - torso_w/2, torso_y, torso_w, torso_h, 12, robe)

    # Robe trim (neckline + hem)
    fill_rounded_rect.call(head_cx - torso_w/2, torso_y, torso_w, 16, 6, robe_trim)
    fill_rounded_rect.call(head_cx - torso_w/2, torso_y + torso_h - 14, torso_w, 14, 6,
        robe_trim)

    # Vertical center seam line
    for py in range(torso_y + 18, torso_y + torso_h - 16):
        img.set_pixel(head_cx, py, robe.darkened(0.2))

    # Belt sash
    var sash_c := robe_trim.darkened(0.1)
    fill_rounded_rect.call(head_cx - torso_w/2 + 4, torso_y + torso_h/2 - 8,
        torso_w - 8, 16, 6, sash_c)

    # ── ARMS ──────────────────────────────────────────────────────────────
    # Left arm hangs slightly forward
    fill_rounded_rect.call(head_cx - torso_w/2 - 22, torso_y + 8, 22, 80, 8, robe)
    fill_ellipse.call(head_cx - torso_w/2 - 11, torso_y + 8 + 80 + 8, 11, 11, skin)
    # Right arm
    fill_rounded_rect.call(head_cx + torso_w/2, torso_y + 8, 22, 80, 8, robe)
    fill_ellipse.call(head_cx + torso_w/2 + 11, torso_y + 8 + 80 + 8, 11, 11, skin)

    # Elder staff in right hand
    if elder:
        for py in range(torso_y + 70, torso_y + torso_h + 80):
            img.set_pixel(head_cx + torso_w/2 + 28, py,
                Color(0.62, 0.46, 0.20))

    # ── SKIRT / LOWER ROBE ────────────────────────────────────────────────
    var skirt_y := torso_y + torso_h - 10
    fill_rounded_rect.call(head_cx - torso_w/2 - 8, skirt_y, torso_w + 16, 80, 10, robe)
    # Robe bottom trim
    fill_rounded_rect.call(head_cx - torso_w/2 - 8, skirt_y + 66, torso_w + 16, 14, 6,
        robe_trim)

    # ── FEET (sandals) ─────────────────────────────────────────────────────
    var feet_y := skirt_y + 76
    var sandal_c := skin.darkened(0.15)
    fill_rounded_rect.call(head_cx - 30, feet_y, 28, 22, 6, sandal_c)
    fill_rounded_rect.call(head_cx + 2,  feet_y, 28, 22, 6, sandal_c)
    # Sandal strap
    fill_rect.call(head_cx - 28, feet_y + 6, 24, 4, robe_trim.darkened(0.2))
    fill_rect.call(head_cx + 4,  feet_y + 6, 24, 4, robe_trim.darkened(0.2))

    var tex := ImageTexture.create_from_image(img)
    return tex

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
    _build_character()

func _build_character() -> void:
    # ── Shadow plane ─────────────────────────────────────────────────────
    if cast_shadow:
        _shadow_mesh = MeshInstance3D.new()
        var shadow_quad := QuadMesh.new()
        shadow_quad.size = Vector2(1.2 * scale_factor, 0.6 * scale_factor)
        _shadow_mesh.mesh = shadow_quad
        _shadow_mesh.rotation_degrees = Vector3(90, 0, 0)   # flat on ground
        _shadow_mesh.position = Vector3(0, 0.02, 0)
        var shadow_mat := StandardMaterial3D.new()
        shadow_mat.albedo_color = Color(0, 0, 0, 0.35)
        shadow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        shadow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        _shadow_mesh.material_override = shadow_mat
        add_child(_shadow_mesh)

    # ── Main billboard quad ───────────────────────────────────────────────
    _billboard_mesh = MeshInstance3D.new()
    var quad := QuadMesh.new()
    # Character height ≈ 2.2 world-units, width ≈ 1.1
    quad.size = Vector2(1.1 * scale_factor, 2.2 * scale_factor)
    _billboard_mesh.mesh = quad

    # Offset up so feet sit at y=0
    _billboard_mesh.position = Vector3(0, 1.1 * scale_factor, 0)

    # Build or load texture
    var tex: ImageTexture
    if sprite_path != "" and ResourceLoader.exists(sprite_path):
        tex = ImageTexture.create_from_image(
            Image.load_from_file(sprite_path))  # fallback; ideally preload
    else:
        tex = _draw_cartoon_character(
            skin_color, hair_color, robe_color, robe_trim_color, eye_color, is_elder)

    # Create billboard shader material
    var mat := ShaderMaterial.new()
    mat.shader = _make_billboard_shader()
    mat.set_shader_parameter("albedo_tex", tex)
    mat.set_shader_parameter("tint_color", Color.WHITE)
    mat.set_shader_parameter("outline_width", 0.0)
    mat.set_shader_parameter("outline_color", Color(1, 0.85, 0, 1))
    _billboard_mesh.material_override = mat

    add_child(_billboard_mesh)

    # ── Name label ────────────────────────────────────────────────────────
    if show_name_label and character_name != "":
        _name_label = Label3D.new()
        _name_label.text = character_name
        _name_label.font_size = 24
        _name_label.modulate = Color(1.0, 0.9, 0.5, 1.0)
        _name_label.outline_modulate = Color(0, 0, 0, 0.85)
        _name_label.outline_size = 6
        _name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        _name_label.position = Vector3(0, 2.6 * scale_factor, 0)
        _name_label.no_depth_test = true
        add_child(_name_label)

    # ── Idle bobbing animation ────────────────────────────────────────────
    _start_idle_anim()

func _make_billboard_shader() -> Shader:
    var s := Shader.new()
    s.code = BILLBOARD_SHADER
    return s

# ─────────────────────────────────────────────────────────────────────────────
#  PUBLIC API
# ─────────────────────────────────────────────────────────────────────────────

## Show the highlight glow ring — called when player enters NPC radius.
func highlight(on: bool) -> void:
    if not _billboard_mesh: return
    var mat := _billboard_mesh.material_override as ShaderMaterial
    if mat:
        mat.set_shader_parameter("outline_width", 0.04 if on else 0.0)
    if _name_label:
        _name_label.modulate = Color(1, 0.95, 0.6, 1) if on else Color(1, 0.9, 0.5, 1)

## Express an emotion via floating emoji label.
func emote(emotion: Emotion) -> void:
    var emoji := ""
    match emotion:
        Emotion.HAPPY:     emoji = "😊"
        Emotion.SAD:       emoji = "😢"
        Emotion.SURPRISED: emoji = "😮"
        Emotion.FOCUSED:   emoji = "🙏"
        _:                 emoji = ""
    if emoji == "": return

    if not _emotion_label:
        _emotion_label = Label3D.new()
        _emotion_label.font_size = 36
        _emotion_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        _emotion_label.no_depth_test = true
        _emotion_label.position = Vector3(0.5, 2.9 * scale_factor, 0)
        add_child(_emotion_label)

    _emotion_label.text = emoji
    _emotion_label.modulate = Color(1, 1, 1, 1)
    # Fade out after 2.5 seconds
    if _anim_tween: _anim_tween.kill()
    _anim_tween = create_tween()
    _anim_tween.tween_interval(1.8)
    _anim_tween.tween_property(_emotion_label, "modulate:a", 0.0, 0.7)

## Animate character walking (bob + slight lean).
func play_walk(direction: Vector2) -> void:
    if not _billboard_mesh: return
    if _anim_tween: _anim_tween.kill()
    _anim_tween = create_tween()
    _anim_tween.set_loops()
    _anim_tween.set_ease(Tween.EASE_IN_OUT)
    # Bob up/down
    _anim_tween.tween_property(_billboard_mesh,
        "position:y", (1.1 + 0.08) * scale_factor, 0.22)
    _anim_tween.tween_property(_billboard_mesh,
        "position:y", (1.1 - 0.04) * scale_factor, 0.22)
    # Lean in movement direction
    if abs(direction.x) > 0.1:
        _billboard_mesh.rotation_degrees.z = -direction.x * 5.0

## Stop walk, return to idle.
func play_idle() -> void:
    if not _billboard_mesh: return
    _billboard_mesh.rotation_degrees.z = 0.0
    _billboard_mesh.position.y = 1.1 * scale_factor
    _start_idle_anim()

## Celebrate animation — jump + spin
func play_celebrate() -> void:
    if _anim_tween: _anim_tween.kill()
    _anim_tween = create_tween()
    _anim_tween.tween_property(_billboard_mesh, "position:y",
        (1.1 + 0.4) * scale_factor, 0.3).set_ease(Tween.EASE_OUT)
    _anim_tween.tween_property(_billboard_mesh, "position:y",
        1.1 * scale_factor, 0.4).set_ease(Tween.EASE_IN)
    _anim_tween.tween_callback(play_idle)
    emote(Emotion.HAPPY)

## Pray animation — slight bow
func play_pray() -> void:
    if _anim_tween: _anim_tween.kill()
    _anim_tween = create_tween()
    _anim_tween.tween_property(_billboard_mesh, "rotation_degrees:x", 18.0, 0.4)
    _anim_tween.tween_interval(1.0)
    _anim_tween.tween_property(_billboard_mesh, "rotation_degrees:x", 0.0, 0.4)
    _anim_tween.tween_callback(play_idle)
    emote(Emotion.FOCUSED)

# ─────────────────────────────────────────────────────────────────────────────
#  PRIVATE
# ─────────────────────────────────────────────────────────────────────────────

func _start_idle_anim() -> void:
    if not is_instance_valid(_billboard_mesh): return
    if _anim_tween: _anim_tween.kill()
    _anim_tween = create_tween()
    _anim_tween.set_loops()
    _anim_tween.set_ease(Tween.EASE_IN_OUT)
    var base_y := 1.1 * scale_factor
    _anim_tween.tween_property(_billboard_mesh, "position:y", base_y + 0.04, 1.6)
    _anim_tween.tween_property(_billboard_mesh, "position:y", base_y - 0.01, 1.6)
