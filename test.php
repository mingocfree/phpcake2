<?php
/**
 * test.php - Placed in the 'app' directory
 */

// 1. Define constants relative to this file's location
// Since this file is in /app, the core lib is one level up in /lib
if (!defined('DS')) {
    define('DS', DIRECTORY_SEPARATOR);
}

// In your Docker setup, Cake core is at /app/lib
define('ROOT', dirname(__FILE__) . DS . '..'); 
define('CAKE_CORE_INCLUDE_PATH', dirname(__FILE__) . DS . 'lib');

// 2. Bootstrap the CakePHP environment
require CAKE_CORE_INCLUDE_PATH . DS . 'Cake' . DS . 'bootstrap.php';

App::uses('HttpSocket', 'Network/Http');

// --- Configuration ---
$host = "vpc-test-os-bpyreoyowd433gbb63syfku2ku.ap-southeast-1.es.amazonaws.com";
$masterUser = "admin";
$masterPassword = "Mjnhngoc@403";

echo "--- OpenSearch Connection Test ---\n";

$http = new HttpSocket(array(
    'ssl_verify_peer' => true
));

$http->configAuth('Basic', $masterUser, $masterPassword);

try {
    $response = $http->get("https://{$host}/");

    if ($response->isOk()) {
        $data = json_decode($response->body, true);
        echo "Connected to Cluster: " . $data['cluster_name'] . "\n";
        echo "Version: " . $data['version']['number'] . "\n";
    } else {
        echo "Status: " . $response->code . "\n";
        echo "Error: " . $response->body . "\n";
    }
} catch (Exception $e) {
    echo "Fatal Error: " . $e->getMessage() . "\n";
}
