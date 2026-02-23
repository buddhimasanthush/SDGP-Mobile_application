'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Inventories', {
      id: { type: Sequelize.UUID, defaultValue: Sequelize.UUIDV4, primaryKey: true },
      pharmacyId: {
        type: Sequelize.UUID,
        references: { model: 'Pharmacies', key: 'id' },
        onDelete: 'CASCADE'
      },
      medicineId: {
        type: Sequelize.UUID,
        references: { model: 'Medicines', key: 'id' },
        onDelete: 'CASCADE'
      },
      quantity: { type: Sequelize.INTEGER, defaultValue: 0 },
      price: { type: Sequelize.FLOAT, allowNull: false },
      createdAt: { type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') },
      updatedAt: { type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') }
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Inventories');
  }
};
