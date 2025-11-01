<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Traits\UserUtils;

class UsersTableSeeder extends Seeder
{
    use UserUtils;
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        // Create super admin account
        $adminUser = User::create([
            'name' => 'SuperAdmin',
            'email' => 'admin@busshuttles.com',
            'password' => Hash::make('admin123456'),
            'role' => 0,
            'status_id' => 1,
            'uid' => "ONa9pdXZdQZ0RnIZHPLNSTGIRam1"
        ]);
        $this->storeAvatar($adminUser);
    }
}
