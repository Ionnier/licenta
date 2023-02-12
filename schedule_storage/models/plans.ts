import * as Sequelize from 'sequelize';
import { DataTypes, Model, Optional } from 'sequelize';
import type { activities, activitiesId } from './activities';
import type { tasks, tasksId } from './tasks';

export interface plansAttributes {
  planid: number;
  parentid?: number;
  name?: string;
  startsat?: number;
  endsat?: number;
  createdat?: number;
  modifiedat?: number;
  completed?: number;
}

export type plansPk = "planid";
export type plansId = plans[plansPk];
export type plansOptionalAttributes = "planid" | "parentid" | "name" | "startsat" | "endsat" | "createdat" | "modifiedat" | "completed";
export type plansCreationAttributes = Optional<plansAttributes, plansOptionalAttributes>;

export class plans extends Model<plansAttributes, plansCreationAttributes> implements plansAttributes {
  planid!: number;
  parentid?: number;
  name?: string;
  startsat?: number;
  endsat?: number;
  createdat?: number;
  modifiedat?: number;
  completed?: number;

  // plans hasMany activities via planid
  activities!: activities[];
  getActivities!: Sequelize.HasManyGetAssociationsMixin<activities>;
  setActivities!: Sequelize.HasManySetAssociationsMixin<activities, activitiesId>;
  addActivity!: Sequelize.HasManyAddAssociationMixin<activities, activitiesId>;
  addActivities!: Sequelize.HasManyAddAssociationsMixin<activities, activitiesId>;
  createActivity!: Sequelize.HasManyCreateAssociationMixin<activities>;
  removeActivity!: Sequelize.HasManyRemoveAssociationMixin<activities, activitiesId>;
  removeActivities!: Sequelize.HasManyRemoveAssociationsMixin<activities, activitiesId>;
  hasActivity!: Sequelize.HasManyHasAssociationMixin<activities, activitiesId>;
  hasActivities!: Sequelize.HasManyHasAssociationsMixin<activities, activitiesId>;
  countActivities!: Sequelize.HasManyCountAssociationsMixin;
  // plans belongsTo tasks via parentid
  parent!: tasks;
  getParent!: Sequelize.BelongsToGetAssociationMixin<tasks>;
  setParent!: Sequelize.BelongsToSetAssociationMixin<tasks, tasksId>;
  createParent!: Sequelize.BelongsToCreateAssociationMixin<tasks>;

  static initModel(sequelize: Sequelize.Sequelize): typeof plans {
    return plans.init({
    planid: {
      autoIncrement: true,
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true
    },
    parentid: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'tasks',
        key: 'taskid'
      }
    },
    name: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    startsat: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    endsat: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    createdat: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    modifiedat: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    completed: {
      type: DataTypes.INTEGER,
      allowNull: true
    }
  }, {
    sequelize,
    tableName: 'plans',
    schema: 'public',
    timestamps: false,
    indexes: [
      {
        name: "plans_pkey",
        unique: true,
        fields: [
          { name: "planid" },
        ]
      },
    ]
  });
  }
}
