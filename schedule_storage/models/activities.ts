import * as Sequelize from 'sequelize';
import { DataTypes, Model, Optional } from 'sequelize';
import type { plans, plansId } from './plans';
import type { tasks, tasksId } from './tasks';

export interface activitiesAttributes {
  activityid: number;
  parentid?: number;
  planid?: number;
  comment?: string;
  startedat?: number;
  timespent?: number;
  createdat?: number;
  modifiedat?: number;
}

export type activitiesPk = "activityid";
export type activitiesId = activities[activitiesPk];
export type activitiesOptionalAttributes = "activityid" | "parentid" | "planid" | "comment" | "startedat" | "timespent" | "createdat" | "modifiedat";
export type activitiesCreationAttributes = Optional<activitiesAttributes, activitiesOptionalAttributes>;

export class activities extends Model<activitiesAttributes, activitiesCreationAttributes> implements activitiesAttributes {
  activityid!: number;
  parentid?: number;
  planid?: number;
  comment?: string;
  startedat?: number;
  timespent?: number;
  createdat?: number;
  modifiedat?: number;

  // activities belongsTo plans via planid
  plan!: plans;
  getPlan!: Sequelize.BelongsToGetAssociationMixin<plans>;
  setPlan!: Sequelize.BelongsToSetAssociationMixin<plans, plansId>;
  createPlan!: Sequelize.BelongsToCreateAssociationMixin<plans>;
  // activities belongsTo tasks via parentid
  parent!: tasks;
  getParent!: Sequelize.BelongsToGetAssociationMixin<tasks>;
  setParent!: Sequelize.BelongsToSetAssociationMixin<tasks, tasksId>;
  createParent!: Sequelize.BelongsToCreateAssociationMixin<tasks>;

  static initModel(sequelize: Sequelize.Sequelize): typeof activities {
    return activities.init({
    activityid: {
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
    planid: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'plans',
        key: 'planid'
      }
    },
    comment: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    startedat: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    timespent: {
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
    }
  }, {
    sequelize,
    tableName: 'activities',
    schema: 'public',
    timestamps: false,
    indexes: [
      {
        name: "activities_pkey",
        unique: true,
        fields: [
          { name: "activityid" },
        ]
      },
    ]
  });
  }
}
