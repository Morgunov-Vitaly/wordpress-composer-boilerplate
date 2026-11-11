<?php

declare(strict_types=1);

use Dotenv\Dotenv;

$projectRoot = dirname(__DIR__);

$autoload = $projectRoot . '/vendor/autoload.php';
if (is_readable($autoload)) {
    require_once $autoload;
}

if (class_exists(Dotenv::class) && file_exists($projectRoot . '/.env')) {
    Dotenv::createImmutable($projectRoot)->safeLoad();
}

define('WP_ENVIRONMENT_TYPE', $_ENV['WP_ENV'] ?? 'production');
define('WP_HOME', $_ENV['WP_HOME'] ?? 'http://localhost');
define('WP_SITEURL', $_ENV['WP_SITEURL'] ?? WP_HOME . '/wp');
define('WP_CONTENT_DIR', $projectRoot . '/public/content');
define('WP_CONTENT_URL', WP_HOME . '/content');

define('DB_NAME', $_ENV['DB_NAME'] ?? 'wordpress');
define('DB_USER', $_ENV['DB_USER'] ?? 'root');
define('DB_PASSWORD', $_ENV['DB_PASSWORD'] ?? '');
define('DB_HOST', $_ENV['DB_HOST'] ?? '127.0.0.1');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');
$table_prefix = $_ENV['DB_PREFIX'] ?? 'wp_';

foreach ([
    'AUTH_KEY', 'SECURE_AUTH_KEY', 'LOGGED_IN_KEY', 'NONCE_KEY',
    'AUTH_SALT', 'SECURE_AUTH_SALT', 'LOGGED_IN_SALT', 'NONCE_SALT',
] as $constant) {
    define($constant, $_ENV[$constant] ?? 'change-this-before-production');
}

define('DISALLOW_FILE_EDIT', true);
define('WP_DEBUG', WP_ENVIRONMENT_TYPE === 'development');
define('WP_DEBUG_LOG', WP_DEBUG);
define('WP_DEBUG_DISPLAY', false);
if (!defined('ABSPATH')) {
    define('ABSPATH', $projectRoot . '/public/wp/');
}

$environment = WP_ENVIRONMENT_TYPE;
$environmentFile = __DIR__ . '/environments/' . $environment . '.php';
if (is_readable($environmentFile)) {
    require_once $environmentFile;
}
