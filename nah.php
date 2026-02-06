<?php
// 1. Manually define the paths CakePHP 2 needs
define('DS', DIRECTORY_SEPARATOR);

// ROOT should be the parent of the app directory. 
// In your docker, everything is in /app
define('ROOT', DS . 'app'); 

// The directory name of your application
define('APP_DIR', 'app');

// The absolute path to your app directory
define('APP', ROOT . DS . APP_DIR . DS);

// Path to the Cake framework core
define('CAKE_CORE_INCLUDE_PATH', ROOT . DS . 'lib');

// Define webroot (needed for bootstrap)
define('WWW_ROOT', APP . 'webroot' . DS);

// 2. Load the Bootstrap
require CAKE_CORE_INCLUDE_PATH . DS . 'Cake' . DS . 'bootstrap.php';

// 3. Now we can use Cake classes
App::uses('HttpSocket', 'Network/Http');

// --- Configuration ---
$host = "vpc-test-os-bpyreoyowd433gbb63syfku2ku.ap-southeast-1.es.amazonaws.com";
$masterUser = "admin";
$masterPassword = "Mjnhngoc@403";

echo "--- OpenSearch Connection Test ---\n";

$http = new HttpSocket(array(
    'ssl_verify_peer' => false // Set to true once working
));

$http->configAuth('Basic', $masterUser, $masterPassword);

try {
    $response = $http->get("https://{$host}/");

    if ($response->isOk()) {
        $data = json_decode($response->body, true);
        echo "SUCCESS!\n";
        echo "Cluster Name: " . $data['cluster_name'] . "\n";
    } else {
        echo "HTTP Status: " . $response->code . "\n";
        echo "Error: " . $response->body . "\n";
    }
} catch (Exception $e) {
    echo "Fatal Error: " . $e->getMessage() . "\n";
}
