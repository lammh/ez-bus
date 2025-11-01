<?php 

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AuthSetting extends Model
{
    use HasFactory;

    // keep guarded as originally
    protected $guarded = ['id', 'created_at', 'updated_at', 'deleted_at'];

    /**
     * Always treat the system as activated in this environment.
     */
    public function isActivated(): bool
    {
        return true;
    }

    /**
     * Provide safe dummy values for keys so other code doesn't hit nulls.
     */
    public function getSecureKeyAttribute($value)
    {
        return $value ?? 'NO_LICENSE_NEEDED';
    }

    public function getU1Attribute($value)
    {
        return $value ?? 'DUMMY_U1';
    }

    public function getU2Attribute($value)
    {
        return $value ?? 'DUMMY_U2';
    }

    public function getU3Attribute($value)
    {
        return $value ?? 'DUMMY_U3';
    }

    /**
     * Static helper if any code checks statically.
     */
    public static function activated(): bool
    {
        return true;
    }
}
