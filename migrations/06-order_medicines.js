'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('OrderMedicines', {
      orderId: {
        type: Sequelize.UUID,
        references: { model: 'Orders', key: 'id' },
        onDelete: 'CASCADE',
        primaryKey: true
      },
      medicineId: {
        type: Sequelize.UUID,
        references: { model: 'Medicines', key: 'id' },
        onDelete: 'CASCADE',
        primaryKey: true
      },
      quantity: { type: Sequelize.INTEGER, defaultValue: 1 },
      createdAt: { type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') },
      updatedAt: { type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') }
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('OrderMedicines');
  }
};
