# Game Design Document: Twelve Stones

## Executive Summary

**Title:** Twelve Stones  
**Genre:** Educational Adventure / Biblical Exploration  
**Platform:** Cross-platform (iOS, Android, macOS, Windows, Ubuntu)  
**Engine:** Godot 4.3  
**Target Audience:** All Ages (with content guidelines)  
**Core Theme:** Journey through the 12 Tribes of Israel, collecting memorial stones while learning biblical history and scripture

---

## Vision Statement

*Twelve Stones* is an immersive biblical adventure game that combines education with engaging gameplay. Players embark on a spiritual journey through ancient Israel, meeting tribal elders, completing challenges, memorizing scripture, and collecting memorial stones that commemorate God's faithfulness to His people.

---

## Core Gameplay Loop

The game follows a structured, repeating cycle that drives player progression:

```
1. EXPLORE
   └─> Navigate the world map to discover tribal territories
       
2. MEET ELDER
   └─> Encounter tribal elder who shares history and wisdom
       
3. CHALLENGE
   └─> Complete tribe-specific mini-game challenge
       
4. MEMORIZE
   └─> Learn and recite key scripture verse
       
5. COLLECT
   └─> Receive memorial stone upon completion
       
6. BUILD
   └─> Place stone in the memorial to mark progress
       
   └─> REPEAT until all 12 stones are collected
```

---

## Detailed Roadmap

### Phase 1: Foundation (Current)
- [x] Basic game structure and menu system
- [x] Global state management (tribes, avatars, stones, verses)
- [x] Multiplayer lobby framework
- [ ] World map with 12 tribal territories
- [ ] Elder character models and dialogue system

### Phase 2: Core Mechanics
- [ ] Implement all 12 tribe-specific mini-games
- [ ] Scripture memorization system
- [ ] Stone collection and memorial building
- [ ] Progress tracking and save system
- [ ] Achievement system

### Phase 3: Content & Polish
- [ ] Complete all 12 tribal narratives
- [ ] Biblical accuracy review and verification
- [ ] Professional voice acting for elders (optional)
- [ ] Original soundtrack with Middle Eastern instruments
- [ ] Visual polish and effects

### Phase 4: Expansion & Deployment
- [ ] Multiplayer competitive modes
- [ ] Additional challenge difficulties
- [ ] Export to all target platforms
- [ ] App store submissions
- [ ] Community feedback and updates

---

## Victory Conditions

### Primary Victory
**Complete Memorial:** Collect all 12 memorial stones by:
- Meeting all 12 tribal elders
- Completing all 12 challenges
- Memorizing all 12 key scripture verses
- Building the complete memorial

### Secondary Achievements
- **Perfect Recall:** Recite all verses without hints
- **Speed Runner:** Complete all challenges under par time
- **Biblical Scholar:** Discover all optional historical facts
- **Master Builder:** Construct the memorial with perfect placement
- **Faithful Witness:** Complete the journey without skipping any content

---

## Narrative Arc

### Act 1: The Call (Tribes 1-4)
**Theme:** Foundation and Promise

The player is called to embark on a journey through Israel, learning about God's covenant with His people. They meet the first four tribes and learn foundational truths.

- **Reuben** - The firstborn, learning about trust and redemption
- **Simeon** - Justice and transformation
- **Levi** - Worship and priesthood
- **Judah** - Leadership and the coming Messiah

### Act 2: The Journey (Tribes 5-8)
**Theme:** Growth and Testing

The middle journey tests the player's understanding and challenges them to apply what they've learned. Difficulties increase as wisdom deepens.

- **Dan** - Discernment between truth and deception
- **Naphtali** - Swiftness and freedom in obedience
- **Gad** - Fortitude in the face of adversity
- **Asher** - Blessing and contentment

### Act 3: The Fulfillment (Tribes 9-12)
**Theme:** Purpose and Completion

The final tribes reveal the ultimate purpose of the journey - understanding God's faithfulness and preparing for His kingdom.

- **Issachar** - Wisdom and timing
- **Zebulun** - Safe harbor and refuge
- **Joseph** - Fruitfulness through trials
- **Benjamin** - Protection and favor

### Finale: The Memorial
Upon collecting all stones, players participate in a ceremonial placement of the memorial, recreating the biblical tradition of setting up stones of remembrance (Joshua 4:1-9). A final celebration recounts the journey and reveals the deeper spiritual meaning.

---

## Game Progression System

### Linear Progression
Tribes are unlocked sequentially to ensure proper narrative flow and difficulty scaling.

### Difficulty Scaling
- **Early Tribes (1-4):** Tutorial-like, forgiving challenges
- **Middle Tribes (5-8):** Standard difficulty, requires skill
- **Late Tribes (9-12):** Advanced challenges, mastery required

### Reward Structure
Each tribe completion grants:
- 1 Memorial Stone
- 1 Scripture Verse (added to collection)
- Tribal Badge/Achievement
- Unlocks next tribe territory
- Story progression

---

## Key Game Systems

### 1. World Navigation
- **Overworld Map:** Visual representation of ancient Israel
- **Tribal Territories:** Distinct visual themes per tribe
- **Fast Travel:** Unlocked after first visit (quality of life)

### 2. Dialogue System
- **Elder Interactions:** Branching dialogue with historical context
- **Voiced Narration:** Optional for accessibility
- **Text Display:** Clear, readable fonts supporting Hebrew characters

### 3. Mini-Game Framework
- **Modular Design:** Each mini-game is self-contained
- **Difficulty Options:** Easy/Normal/Hard for accessibility
- **Performance Grading:** Bronze/Silver/Gold completion tiers

### 4. Scripture Memory
- **Progressive Hints:** Starts with full text, removes words gradually
- **Audio Playback:** Hear verse spoken aloud
- **Spaced Repetition:** Periodic review of previously learned verses

### 5. Memorial Building
- **Visual Representation:** 3D or stylized 2D memorial structure
- **Stone Placement:** Interactive ceremony after each collection
- **Progress Tracking:** Clear visual indicator of completion (X/12)

---

## Multiplayer Features

### Cooperative Mode
- Players journey together through tribes
- Take turns completing challenges
- Share scripture memorization
- Build memorial together

### Competitive Mode (Future)
- Race to complete challenges faster
- Scripture recitation accuracy contest
- Leaderboards for each tribe
- Time trials

---

## Accessibility Features

- **Difficulty Settings:** Adjustable challenge levels
- **Text Size Options:** Scalable UI text
- **Colorblind Modes:** Alternative color palettes
- **Audio Options:** Subtitles, volume controls
- **Skip Options:** Allow progression without perfect scores (with reduced rewards)

---

## Technical Architecture

### Scene Structure
```
MainMenu
  ├─> AvatarPick (Player customization)
  ├─> WorldMap (Hub for tribal territories)
  │     ├─> TribeTerritory_1-12 (Individual tribal areas)
  │     │     ├─> ElderDialogue
  │     │     ├─> MiniGame
  │     │     └─> ScriptureMemory
  │     └─> Memorial (Final destination)
  └─> Lobby (Multiplayer)
```

### Global State Management
- **Global.gd:** Tracks progress, stones, verses, achievements
- **SaveSystem:** Persistent data storage
- **MultiplayerLobby.gd:** Network synchronization

---

## Development Priorities

1. **Biblical Accuracy:** All content must be theologically sound
2. **Age Appropriateness:** Content suitable for all audiences
3. **Educational Value:** Players should learn while having fun
4. **Engagement:** Gameplay must be compelling, not just educational
5. **Accessibility:** Everyone should be able to experience the game
6. **Cross-Platform:** Seamless experience across all devices

---

## Success Metrics

### Player Engagement
- Average session length
- Completion rate (% of players finishing all 12 tribes)
- Return rate (players coming back after first session)

### Educational Impact
- Scripture retention (tested through in-game quizzes)
- Player feedback on learning experience
- Educational institution adoption

### Technical Performance
- Load times under 3 seconds
- 60 FPS on all target platforms
- Zero critical bugs at launch

---

## Future Expansion Possibilities

- **DLC: New Testament Journeys** - Follow the apostles
- **Challenge Mode:** Remixed harder versions of mini-games
- **Creator Mode:** Community-created challenges
- **Study Mode:** Deep-dive into tribal history
- **VR Support:** Immersive biblical world exploration

---

## Conclusion

*Twelve Stones* aims to create a meaningful, engaging experience that honors biblical history while providing modern, accessible gameplay. Through careful attention to accuracy, engaging mechanics, and thoughtful progression, players will not only enjoy the game but also gain a deeper appreciation for the heritage of the twelve tribes and God's faithfulness throughout history.

**Core Message:** Just as the Israelites set up stones to remember God's faithfulness, players will build their own memorial of faith through this interactive journey.

---

*Document Version: 1.0*  
*Last Updated: 2026-02-18*  
*Next Review: Phase 2 Completion*
