<template>
  <div>
    <vue-element-loading :active="submiting" />
    <v-card>
      <!-- Page Heading -->
      <v-card-title>
        <span class="me-3">On-Route Trips</span>
        <v-spacer></v-spacer>
        <!-- <v-btn depressed color="secondary" @click="$router.go(-1)" class="mx-1">
          Back
          <v-icon right dark> mdi-keyboard-return </v-icon>
        </v-btn> -->
      </v-card-title>
      <v-card-text>
        <div class="row">
            <div v-if="on_route_trips.length === 0" class="col-md-4 text-center py-10">
                <v-icon size="100" class="py-10">mdi-bus-alert</v-icon>
                <h3>No on-route trips</h3>
            </div>
          <div v-else class="col-md-4">
                <div
                  class="list-group-item py-6 my-2"
                  :class="selectedIdx == index ? 'active-stop' : ''"
                  v-for="(element, index) in on_route_trips"
                  :key="element.id"
                  @click="
                    selectedItem = element.channel;
                    selectedIdx = index;
                  "
                >
                <div v-if="element.driver" class="d-flex align-center">
                    <v-icon size="30" class="mr-2">mdi-bus</v-icon>
                    <div class="font-weight-bold text-dark m-1 my-1">
                    {{ element.driver.name }}
                    </div>
                </div>
                <div class="text-dark m-1 my-1 ml-1" v-if="element.trip && element.trip.route">
                    <v-icon size="25" class="mr-2">mdi-road-variant</v-icon>
                    {{ element.trip.route.name }}
                </div>
                <div class="text-dark m-1 my-1 ml-1">
                    <v-icon size="25" class="mr-2">mdi-clock-time-four-outline</v-icon>
                    {{ element.started_at }}
                </div>
                </div>
          </div>
          <div class="col-md-8" id="map">
            <GoogleMapLoader
              :enabled="false"
              :center="center"
              :selected="selectedItem"
              :zoom="zoom"
              :apiKey="apiKey"
              :markers="markers"
              :polylines="polyline"
            >
            </GoogleMapLoader>
          </div>
        </div>
      </v-card-text>
    </v-card>
  </div>
</template>

<script>
// $(window).scroll(function () {
//   $("#map")
//     .stop()
//     .animate(
//       {
//         marginTop: $(window).scrollTop() + "px",
//         marginLeft: $(window).scrollLeft() + "px",
//       },
//       "slow"
//     );
// });

import GoogleMapLoader from "../../components/GoogleMapLoader.vue";

import VueElementLoading from "vue-element-loading";
import {Keys} from '/src/config.js'

export default {
  components: {
    GoogleMapLoader,
    VueElementLoading,
    Keys
  },

  data() {
    return {
      apiKey: Keys.GOOGLE_MAPS_API_KEY,
      markers: [],
      selectedIdx: null,
      currentPlace: null,
      on_route_trips: [],
      directions: [],
      polyline:[],
      center: {
        lat: Keys.VUE_APP_ORIGIN_LAT,
        lng: Keys.VUE_APP_ORIGIN_LNG,
      },
      zoom: 12,
      selectedItem: null,
      submiting: false,
      mode: null, //0: create, 1 edit
    };
  },
  mounted() {
    this.center.lat = parseFloat(this.center.lat);
    this.center.lng = parseFloat(this.center.lng);
    this.fetchOnRouteTrips();
  },
  methods: {
    addBusIcon(on_route_trip) {
        const position = {
          lat: parseFloat(on_route_trip.last_position_lat),
          lng: parseFloat(on_route_trip.last_position_lng),
        };
        let infoText = this.getTripInfoText(on_route_trip);

        let marker = {
          place_id: on_route_trip.channel,
          position: position,
          infoText: infoText,
        };
        //change the marker icon to bus
        const image = "https://cdn-icons-png.flaticon.com/32/3471/3471521.png";
        marker.icon = image;
        this.markers.push(marker);
    },
    getTripInfoText(on_route_trip, speed = null) {
      let infoText = "";
      if (on_route_trip.driver) {
        infoText += "<b>Driver:</b> " + on_route_trip.driver.name + "<br/>";
      }
      if (on_route_trip.trip && on_route_trip.trip.route) {
        infoText += "<b>Route:</b> " + on_route_trip.trip.route.name + "<br/>";
      }
      if(speed)
      {
        infoText += "<b>Speed:</b> " + speed + " km/h<br/>";
      }
      return infoText;
    },
    //API Calls
    fetchOnRouteTrips() {
      this.submiting = true;
      axios
        .get('/planned-trips/on-route')
        .then((response) => {
          this.submiting = false;
          this.on_route_trips = response.data.running;
          if(this.on_route_trips.length>0)
          {
          for (let index = 0; index < this.on_route_trips.length; index++) {
             this.addBusIcon(this.on_route_trips[index]);
            }
            this.listenToChannels();
          }
        })
        .catch((error) => {
          this.submiting = false;
          this.$notify({
            title: "Error",
            text: "Error fetching on_route_trips of this route",
            type: "error",
          });
          console.log(error);
          this.$router.go(-1);
          //this.$swal("Error", error.response.data.message, "error");
        });
    },
    listenToChannels() {
      for (let index = 0; index < this.on_route_trips.length; index++) {
        this.listenToChannel(index, this.on_route_trips[index]);
      }
    },
    listenToChannel(index, trip) {
      window.Echo.channel(trip.channel).listen("TripPositionUpdated",
      (e) => {
        if (this.selectedItem == trip.channel)
        {
        //update the marker position
        let data = e.data;
        //parse the data as json
        data = JSON.parse(data);
        let lat = data.lat;
        let lng = data.lng;
        //convert lat and lng to float if they are strings
        lat = parseFloat(lat);
        lng = parseFloat(lng);
        let speed = data.speed;
        //approximate the speed to 2 decimal places
        speed = Math.round(speed * 100) / 100;
        let position = {
          lat: lat,
          lng: lng,
        };
        let marker = this.markers[index];
        marker.position = position;
        let infoText = this.getTripInfoText(trip, speed);
        marker.infoText = infoText;
        this.center = position;
        this.selectedItem = null;
        //delay some time
          setTimeout(() => {
              this.selectedItem = trip.channel;
          }, 10);
        }
      });
    },
  },
};
</script>

<style>
.flip-list-move {
  transition: transform 0.5s;
}

.no-move {
  transition: transform 0s;
}

.ghost {
  opacity: 0.5;
  background: #c8ebfb;
}

.list-group {
  min-height: 20px;
}

.list-group-item {
  cursor: pointer;
}

.list-group-item i {
  cursor: pointer;
}

.v-application ul {
  padding-left: 12px !important;
}

.gm-style .gm-style-iw-d {
  color: #0d508b !important;
}

</style>

<style lang="scss">
.active-stop {
  background: rgba($primary-shade--light, 0.15) !important;
}
</style>
