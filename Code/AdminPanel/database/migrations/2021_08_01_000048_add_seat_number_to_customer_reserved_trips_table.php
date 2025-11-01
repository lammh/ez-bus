<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddSeatNumberToCustomerReservedTripsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('customer_reserved_trips', function (Blueprint $table) {
            $table->integer('seat_number')->nullable()->default(null);
            //row
            $table->integer('row')->nullable()->default(null);
            //column
            $table->integer('column')->nullable()->default(null);

            //make seat_number unique per trip
            $table->unique(['planned_trip_id', 'seat_number'], 'unique_seat_number_per_trip');
        });
    }
    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('customer_reserved_trips', function (Blueprint $table) {
            $table->dropColumn('seat_number');
            $table->dropColumn('row');
            $table->dropColumn('column');
        });
    }
}
