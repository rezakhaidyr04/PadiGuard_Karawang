<?php
require_once 'db.php';

$sql = file_get_contents('database_update.sql');

try {
    $pdo->exec($sql);
    echo "Tabel sawah berhasil dibuat!\n";
} catch (PDOException $e) {
    echo "Gagal membuat tabel sawah: " . $e->getMessage() . "\n";
}
?>
