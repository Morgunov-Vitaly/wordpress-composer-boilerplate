<?php
/**
 * Plugin Name: Project Bootstrap
 * Description: A safe place for project-wide WordPress bootstrap code.
 */

declare(strict_types=1);

add_action('after_setup_theme', static function (): void {
    add_theme_support('title-tag');
    add_theme_support('post-thumbnails');
});
