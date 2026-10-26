<?php

// Issues a login token for the first registered user, the same kind of token a
// password login creates (full access, 14 days).

require '/var/www/cocktails/vendor/autoload.php';

$app = require '/var/www/cocktails/bootstrap/app.php';
$app->make(Illuminate\Contracts\Http\Kernel::class)->bootstrap();

header('Content-Type: application/json');

$user = Kami\Cocktail\Models\User::query()->orderBy('id')->first();
if ($user === null) {
    http_response_code(404);
    echo json_encode(['message' => 'No user has registered yet.']);
    return;
}

$token = $user->createToken('Home Assistant auto-login', expiresAt: now()->addDays(14));
echo json_encode(['token' => $token->plainTextToken]);
