<html>

<head>
</head>

<body>
<h1 style="margin-bottom:-18px">PHP</h1>
<h3>tests de connexion aux bases de données</h3>

<br>

<?php
echo '<h2 style="margin-bottom:-12px">MariaDB</h2>';
$conn = mysqli_connect("127.0.0.1", "test_u", "Test123");
if (!$conn) {
    echo '<p style="color:red;font-weight:bold;">CONNEXION ÉCHOUÉE</p>';
}
else {
    echo '<p style="color:green;font-weight:bold;">CONNECTÉ AVEC SUCCÈS</p>';
}
echo '<br>';
echo '<h2 style="margin-bottom:-12px">PostgreSQL</h2>';
$conn = pg_connect("host=127.0.0.1 dbname=test user=test_u password=Test123");
if (!$conn) {
    echo '<p style="color:red;font-weight:bold;">CONNEXION ÉCHOUÉE</p>';
}
else {
    echo '<p style="color:green;font-weight:bold;">CONNECTÉ AVEC SUCCÈS</p>';
}

?>

</body>

</html>