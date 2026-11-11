<?php

declare(strict_types=1);

$root = dirname(__DIR__);
$requiredFiles = [
    'composer.json',
    'config/application.php',
    'public/index.php',
    'public/wp-config.php',
    'public/content/themes/learning-theme/style.css',
];

foreach ($requiredFiles as $file) {
    if (!is_file($root . '/' . $file)) {
        fwrite(STDERR, "Missing required file: {$file}\n");
        exit(1);
    }
}

echo "Smoke checks passed.\n";
