<?php
/**
 * test.php - Fixed for standalone execution in Docker
 */

// 1. Define Basic Constants
if (!defined('DS')) {
    define('DS', DIRECTORY_SEPARATOR);
}

// 2. Define Paths based on your setup.sh extraction
// ROOT: The base directory ( /app )
// APP_DIR: The name of your application directory ( 'app' )
// CAKE_CORE_INCLUDE_PATH: Path to the lib folder ( /app/lib )
define('ROOT', DS . 'app');
define('APP_DIR', 'app');
define('WWW_ROOT', ROOT . DS . APP_DIR . DS . 'webroot' . DS);
define('CAKE_CORE_INCLUDE_PATH', ROOT . DS . 'lib');

// 3. Define the full APP path ( /app/app/ )
define('APP', ROOT . DS . APP_DIR . DS);

// 4. Bootstrap the CakePHP environment
require CAKE_CORE_INCLUDE_PATH . DS . 'Cake' . DS . 'bootstrap.php';

// Now that the core is loaded, we can use App::uses
App::uses('HttpSocket', 'Network/Http');

// --- Configuration ---
$host = "vpc-test-os-bpyreoyowd433gbb63syfku2ku.ap-southeast-1.es.amazonaws.com";
$masterUser = "admin";
$masterPassword = "Mjnhngoc@403";

echo "--- OpenSearch Connection Test ---\n";

$http = new HttpSocket(array(
    'ssl_verify_peer' => false // Set to true once connection is confirmed
));

$http->configAuth('Basic', $masterUser, $masterPassword);

try {
    $response = $http->get("https://{$host}/");

    if ($response->isOk()) {
        $data = json_decode($response->body, true);
        echo "SUCCESS!\n";
        echo "Cluster Name: " . ($data['cluster_name'] ?? 'Unknown') . "\n";
        echo "Version: " . ($data['version']['number'] ?? 'Unknown') . "\n";
    } else {
        echo "HTTP Status: " . $response->code . "\n";
        echo "Response Body: " . $response->body . "\n";
    }
} catch (Exception $e) {
    echo "Fatal Error: " . $e->getMessage() . "\n";
}
