<?php
// require 'vendor/autoload.php'; // AWS SDK for PHP

use Aws\SecretsManager\SecretsManagerClient;
use Aws\Exception\AwsException;

// AWS Region and Secret ARN
$region = 'eu-north-1';
$secretName = 'arn:aws:secretsmanager:eu-north-1:211125702898:secret:rds!db-324c0acb-9f84-46c9-b039-4cfa0f4e1b88-Y131cc';
$rdsEndpoint = 'rds.c3as6c0gw9zt.eu-north-1.rds.amazonaws.com';
$dbname = 'employee_db';

try {
    // Create Secrets Manager client
    $client = new SecretsManagerClient([
        'version' => 'latest',
        'region'  => $region
    ]);

    // Get the secret from Secrets Manager
    $result = $client->getSecretValue(['SecretId' => $secretName]);
    $secret = json_decode($result['SecretString'], true);

    $username = $secret['username'];
    $password = $secret['password'];

    // Connect to RDS
    $conn = new mysqli($rdsEndpoint, $username, $password, $dbname);

    if ($conn->connect_error) {
        die("<h3 style='color:red;'>Database connection failed: " . $conn->connect_error . "</h3>");
    }

    // Fetch data from table
    $sql = "SELECT * FROM employees";
    $result = $conn->query($sql);

} catch (AwsException $e) {
    die("<h3 style='color:red;'>AWS Error: " . $e->getMessage() . "</h3>");
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Employee Records from MySQL (AWS RDS)</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f8;
            color: #333;
            margin: 0;
            padding: 0;
        }
        header {
            background-color: #007bff;
            color: white;
            padding: 20px;
            text-align: center;
            font-size: 28px;
        }
        table {
            width: 80%;
            margin: 40px auto;
            border-collapse: collapse;
            background: white;
            box-shadow: 0px 2px 10px rgba(0,0,0,0.1);
        }
        th, td {
            padding: 12px 15px;
            border: 1px solid #ccc;
            text-align: left;
        }
        th {
            background-color: #007bff;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        footer {
            text-align: center;
            padding: 20px;
            color: #555;
            font-size: 14px;
        }
    </style>
</head>
<body>

<header>Employee Records from MySQL (AWS RDS)</header>

<table>
    <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Age</th>
        <th>Profession</th>
    </tr>

    <?php
    if ($result && $result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            echo "<tr>
                    <td>{$row['id']}</td>
                    <td>{$row['username']}</td>
                    <td>{$row['age']}</td>
                    <td>{$row['profession']}</td>
                  </tr>";
        }
    } else {
        echo "<tr><td colspan='4' style='text-align:center;'>No records found</td></tr>";
    }

    $conn->close();
    ?>
</table>

<footer>
    Powered by AWS EC2 + RDS + PHP + Secrets Manager<br>
    <strong style="color:green;">CodePipeline has been successfully created.</strong>
</footer>

</body>
</html>
