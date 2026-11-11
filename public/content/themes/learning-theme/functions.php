<?php

declare(strict_types=1);

add_action('wp_enqueue_scripts', static function (): void {
    wp_enqueue_style(
        'learning-theme',
        get_stylesheet_uri(),
        [],
        wp_get_theme()->get('Version')
    );
});
