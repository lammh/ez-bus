<template>
  <div class="bus-configurator">
    <div class="seat-map">
      <div class="bus-header">
    <div class="controls">
      <div class="form-group">
        <v-text-field
            v-model="totalRows"
            @input="updateGrid"
            label="Rows"
            persistent-hint
            required
        ></v-text-field>
      </div>
      <div class="form-group">
        <v-text-field
            v-model="totalColumns"
            @input="updateGrid"
            label="Columns"
            persistent-hint
            required
        ></v-text-field>
      </div>
      <v-btn color="primary" @click="addRow">
        Add Row
      </v-btn>
    </div>
      </div>

      <div class="bus-body my-4">
        <v-row
          v-for="(row, rowIndex) in seatGrid"
          :key="`row-${rowIndex}`"
          class="seat-row"
        >
        <v-col
        cols="3"
        >
        <div>
            <span class="row-number">Row {{ rowIndex + 1 }}</span>
          </div>
          </v-col>
          <div class="seats-container">
            <div
              v-for="(seat, colIndex) in row"
              :key="`seat-${rowIndex}-${colIndex}`"
              class="seat"
              :class="{ 'seat-available': seat, 'seat-empty': !seat }"
              @click="toggleSeat(rowIndex, colIndex)"
            >
              {{ seat ? (rowIndex * totalColumns + colIndex + 1) : '' }}
            </div>
                      <v-btn color="error mr-2" @click="removeRow(rowIndex)" small>
            <v-icon>
                mdi-delete
            </v-icon>
          </v-btn>
          </div>
        </v-row>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BusSeatConfigurator',
    props: {
    initialConfig: {
      type: Object,
      default: null
    }
  },
  data() {
    return {
      totalRows: 5,
      totalColumns: 4,
      seatGrid: [],
      configJson: ''
    };
  },
  created() {
    if (this.initialConfig) {
      this.loadConfiguration(this.initialConfig);
    } else {
      this.initializeGrid();
    }
  },
  methods: {
    initializeGrid() {
      this.seatGrid = [];
      for (let i = 0; i < this.totalRows; i++) {
        // Default configuration: first row has special layout (bus driver area)
        if (i === 0) {
          // First row typically has fewer seats
          const firstRow = Array(this.totalColumns).fill(false);
          // Enable only the last two seats in the first row
          if (this.totalColumns >= 2) {
            firstRow[this.totalColumns - 1] = true;
            firstRow[this.totalColumns - 2] = true;
          }
          this.seatGrid.push(firstRow);
        } else {
          // Regular rows have all seats
          this.seatGrid.push(Array(this.totalColumns).fill(true));
        }
      }

      // Emit the initial configuration
      this.emitConfigChange();
    },

    updateGrid() {
      // Preserve existing configuration as much as possible
      const newGrid = [];

      for (let i = 0; i < this.totalRows; i++) {
        const existingRow = this.seatGrid[i] || Array(this.totalColumns).fill(true);
        const newRow = Array(this.totalColumns).fill(false);

        for (let j = 0; j < this.totalColumns; j++) {
          if (j < existingRow.length) {
            newRow[j] = existingRow[j];
          } else {
            newRow[j] = true; // Default new seats to available
          }
        }

        newGrid.push(newRow);
      }

      this.seatGrid = newGrid;
      this.emitConfigChange();
    },

    toggleSeat(rowIndex, colIndex) {
      if (colIndex === -1) {
        // Toggle first column
        this.seatGrid[rowIndex][0] = !this.isFirstColumnEmpty(rowIndex);
      } else if (colIndex === this.totalColumns) {
        // Toggle last column
        this.seatGrid[rowIndex][this.totalColumns - 1] = !this.isLastColumnEmpty(rowIndex);
      } else {
        // Toggle specific seat
        this.$set(this.seatGrid[rowIndex], colIndex, !this.seatGrid[rowIndex][colIndex]);
      }

      this.emitConfigChange();
    },

    isFirstColumnEmpty(rowIndex) {
      return !this.seatGrid[rowIndex][0];
    },

    isLastColumnEmpty(rowIndex) {
      return !this.seatGrid[rowIndex][this.totalColumns - 1];
    },

    addRow() {
      // Add a new row with all seats enabled
      const newRow = Array(Number(this.totalColumns)).fill(true);
      this.seatGrid.push(newRow);
      this.totalRows = this.seatGrid.length;
      this.emitConfigChange();
    },

    removeRow(rowIndex) {
      if (this.seatGrid.length > 1) {
        this.seatGrid.splice(rowIndex, 1);
        this.totalRows = this.seatGrid.length;
        this.emitConfigChange();
      }
    },

    countTotalSeats() {
      return this.seatGrid.reduce((total, row) => {
        return total + row.filter(seat => seat).length;
      }, 0);
    },

    // Configuration management methods
    getCurrentConfig() {
      return {
        rows: this.totalRows,
        columns: this.totalColumns,
        seatGrid: JSON.parse(JSON.stringify(this.seatGrid)) // Deep clone
      };
    },

    saveConfiguration() {
      const config = this.getCurrentConfig();
      const configJson = JSON.stringify(config, null, 2);
      this.configJson = configJson;
      this.$emit('save-config', config);
    },


    applyLoadedConfig() {
      try {
        const config = JSON.parse(this.configJson);
        this.loadConfiguration(config);
      } catch (e) {
        alert('Invalid configuration JSON. Please check the format and try again.');
      }
    },

    loadConfiguration(config) {
      if (!config || !config.seatGrid) {
        console.error('Invalid configuration object');
        return;
      }

      this.totalRows = config.rows || config.seatGrid.length;
      this.totalColumns = config.columns || (config.seatGrid[0] ? config.seatGrid[0].length : 4);

      // Deep clone the seat grid to avoid reference issues
      this.seatGrid = JSON.parse(JSON.stringify(config.seatGrid));

      //this.emitConfigChange();
    },

    emitConfigChange() {
      this.$emit('config-change', this.getCurrentConfig());
    }
  },
  watch: {
    initialConfig: {
      handler(newConfig) {
        if (newConfig) {
          this.loadConfiguration(newConfig);
        }
      },
      deep: true
    }
  }
};
</script>

<style scoped>
.bus-configurator {
  font-family: Arial, sans-serif;
  max-width: 800px;
  margin: 0 auto;
}

.controls {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
  align-items: center;
}

.form-group {
  display: flex;
  align-items: center;
  gap: 8px;
}

.seat-map {
  border: 2px solid #333;
  border-radius: 8px;
  overflow: hidden;
}

.bus-header {
  background-color: #f0f0f0;
  padding: 15px;
  border-bottom: 2px solid #333;
}

.driver-area {
  width: 60px;
  height: 40px;
  background-color: #999;
  border-radius: 5px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

.bus-body {
  padding: 15px;
}

.seat-row {
  display: flex;
  margin-bottom: 10px;
  gap: 15px;
}

.row-actions {
  display: flex;
  flex-direction: column;
  gap: 5px;
  width: 120px;
}

.row-number {
  font-weight: bold;
}

.seats-container {
  display: flex;
  gap: 10px;
  flex-grow: 1;
}

.seat {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  border-radius: 5px;
  font-weight: bold;
}

.seat-available {
  background-color: #4CAF50;
  color: white;
}

.seat-empty {
  background-color: #f0f0f0;
  border: 1px dashed #ccc;
}

button {
  padding: 5px 10px;
  background-color: #2196F3;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

button.remove-row {
  background-color: #f44336;
}

button.toggle-seat {
  font-size: 12px;
  padding: 2px 5px;
}

.seat-summary {
  margin-top: 20px;
  padding: 15px;
  background-color: #f9f9f9;
  border-radius: 5px;
}
</style>
