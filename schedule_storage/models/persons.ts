import * as Sequelize from 'sequelize';
import { DataTypes, Model, Optional } from 'sequelize';

export interface personsAttributes {
  id: number;
  parentId?: number;
  firstName?: string;
}

export type personsPk = "id";
export type personsId = persons[personsPk];
export type personsOptionalAttributes = "id" | "parentId" | "firstName";
export type personsCreationAttributes = Optional<personsAttributes, personsOptionalAttributes>;

export class persons extends Model<personsAttributes, personsCreationAttributes> implements personsAttributes {
  id!: number;
  parentId?: number;
  firstName?: string;

  // persons belongsTo persons via parentId
  parent!: persons;
  getParent!: Sequelize.BelongsToGetAssociationMixin<persons>;
  setParent!: Sequelize.BelongsToSetAssociationMixin<persons, personsId>;
  createParent!: Sequelize.BelongsToCreateAssociationMixin<persons>;

  static initModel(sequelize: Sequelize.Sequelize): typeof persons {
    return persons.init({
    id: {
      autoIncrement: true,
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true
    },
    parentId: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'persons',
        key: 'id'
      }
    },
    firstName: {
      type: DataTypes.STRING(255),
      allowNull: true
    }
  }, {
    sequelize,
    tableName: 'persons',
    schema: 'public',
    timestamps: false,
    indexes: [
      {
        name: "persons_pkey",
        unique: true,
        fields: [
          { name: "id" },
        ]
      },
    ]
  });
  }
}
