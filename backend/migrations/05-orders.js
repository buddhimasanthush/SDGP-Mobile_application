'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Orders', {
      id: { type: Sequelize.UUID, defaultValue: Sequelize.UUIDV4, primaryKey: true },
      patientId: {
        type: Sequelize.UUID,
        references: { model: 'Users', key: 'id' },
        onDelete: 'CASCADE'
      },
      pharmacyId: {
        type: Sequelize.UUID,
        references: { model: 'Pharmacies', key: 'id' },
        onDelete: 'SET NULL'
      },
      status: { type: Sequelize.ENUM('Pending', 'InTransit', 'Delivered', 'Cancelled'), defaultValue: 'Pending' },
      totalPrice: { type: Sequelize.FLOAT },
      deliveryPartner: { type: Sequelize.STRING },
      createdAt: { type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') },
      updatedAt: { type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') }
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Orders');
  }
};
