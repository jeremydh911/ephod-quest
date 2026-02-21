// Twelve Stones: Ephod Quest - Website JavaScript

document.addEventListener('DOMContentLoaded', function () {
    // Mobile menu toggle
    const hamburger = document.querySelector('.hamburger');
    const navMenu = document.querySelector('.nav-menu');

    if (hamburger && navMenu) {
        hamburger.addEventListener('click', function () {
            navMenu.classList.toggle('active');
            hamburger.classList.toggle('active');
        });
    }

    // Smooth scrolling for navigation links
    const navLinks = document.querySelectorAll('.nav-menu a, .hero-buttons a[href^="#"]');

    navLinks.forEach(link => {
        link.addEventListener('click', function (e) {
            e.preventDefault();

            const targetId = this.getAttribute('href');
            const targetSection = document.querySelector(targetId);

            if (targetSection) {
                const offsetTop = targetSection.offsetTop - 80; // Account for fixed navbar

                window.scrollTo({
                    top: offsetTop,
                    behavior: 'smooth'
                });
            }

            // Close mobile menu after clicking
            if (navMenu.classList.contains('active')) {
                navMenu.classList.remove('active');
                hamburger.classList.remove('active');
            }
        });
    });

    // Add fade-in animation to sections on scroll
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver(function (entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('fade-in');
            }
        });
    }, observerOptions);

    // Observe all sections
    const sections = document.querySelectorAll('.section');
    sections.forEach(section => {
        observer.observe(section);
    });

    // Gallery image modal (simple implementation)
    const galleryImages = document.querySelectorAll('.gallery-img');

    galleryImages.forEach(img => {
        img.addEventListener('click', function () {
            // Create modal
            const modal = document.createElement('div');
            modal.style.cssText = `
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.8);
                display: flex;
                justify-content: center;
                align-items: center;
                z-index: 10000;
                cursor: pointer;
            `;

            const modalImg = document.createElement('img');
            modalImg.src = this.src;
            modalImg.style.cssText = `
                max-width: 90%;
                max-height: 90%;
                object-fit: contain;
                border-radius: 10px;
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
            `;

            modal.appendChild(modalImg);
            document.body.appendChild(modal);

            // Close modal on click
            modal.addEventListener('click', function () {
                document.body.removeChild(modal);
            });
        });
    });

    // Download button tracking (placeholder for analytics)
    const downloadButtons = document.querySelectorAll('.download-btn, .btn-primary');

    downloadButtons.forEach(btn => {
        btn.addEventListener('click', function () {
            // Placeholder for analytics tracking
            console.log('Download button clicked:', this.textContent || this.className);

            // You could add Google Analytics, Facebook Pixel, etc. here
            // Example: gtag('event', 'click', { event_category: 'download', event_label: this.textContent });
        });
    });

    // Form validation for contact/newsletter (if added later)
    // This is a placeholder for future form handling

    // Parallax effect for hero background (subtle)
    window.addEventListener('scroll', function () {
        const scrolled = window.pageYOffset;
        const hero = document.querySelector('.hero');

        if (hero) {
            const rate = scrolled * -0.5;
            hero.style.backgroundPosition = `center ${rate}px`;
        }
    });

    // Add loading animation for images
    const images = document.querySelectorAll('img');

    images.forEach(img => {
        img.addEventListener('load', function () {
            this.style.opacity = '1';
        });

        // Set initial opacity to 0 for fade-in effect
        if (!img.complete) {
            img.style.opacity = '0';
            img.style.transition = 'opacity 0.3s ease';
        }
    });

    // Console message for developers
    console.log(`
    ╔══════════════════════════════════════════════════════════════╗
    ║                    Twelve Stones: Ephod Quest                ║
    ║                    Website - Developer Console               ║
    ║                                                              ║
    ║  Welcome! This game combines faith, education, and fun.     ║
    ║  Built with Godot 4.3+ and modern web technologies.         ║
    ║                                                              ║
    ║  For more info: https://github.com/jeremydh911/ephod-quest    ║
    ╚══════════════════════════════════════════════════════════════╝
    `);
});