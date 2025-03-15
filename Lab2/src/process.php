<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $name = trim($_POST['name']);
    $email = trim($_POST['email']);
    $password = $_POST['password'];
    $confirm_password = $_POST['confirm_password'];

    $errors = [];

    if (empty($name)) {
        $errors['name_error'] = "Name cannot be empty.";
    }

    if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors['email_error'] = "Enter a valid email.";
    }

    if ($password !== $confirm_password) {
        $errors['password_error'] = "Passwords do not match.";
    }

    if (!empty($errors)) {
        // Redirect back with errors
        header("Location: index.html?" . http_build_query($errors));
        exit;
    }

    // Show confirmation message
    echo "<h2>Yoo Registration Successful!</h2>";
    echo "<p><strong>Name:</strong> $name</p>";
    echo "<p><strong>Email:</strong> $email</p>";
} else {
    echo "<h2>Invalid Request</h2>";
}
?>
