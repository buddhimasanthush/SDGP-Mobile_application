'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Inventories', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      pharmacyId: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: 'Pharmacies', key: 'id' },
        onDelete: 'CASCADE'
      },
      medicineId: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: 'Medicines', key: 'id' },
        onDelete: 'CASCADE'
      },
      stockQuantity: { type: Sequelize.INTEGER, allowNull: false, defaultValue: 0 },
      unitPrice: { type: Sequelize.FLOAT, allowNull: false, defaultValue: 0 },
      createdAt: { type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') },
      updatedAt: { type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') }
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Inventories');
  }
};
