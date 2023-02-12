import * as Sequelize from 'sequelize';
import { DataTypes, Model, Optional } from 'sequelize';
import type { activities, activitiesId } from './activities';
import type { plans, plansId } from './plans';

export interface tasksAttributes {
  taskid: number;
  parentid?: number;
  title: string;
  description?: string;
  totaltimeestimated?: number;
  remainingtimeestimated?: number;
  prefferedsessiontime?: number;
  priority?: number;
  completed?: number;
  archived?: number;
  createdat?: number;
  lastcompletedat?: number;
  modifiedat?: number;
}

export type tasksPk = "taskid";
export type tasksId = tasks[tasksPk];
export type tasksOptionalAttributes = "taskid" | "parentid" | "description" | "totaltimeestimated" | "remainingtimeestimated" | "prefferedsessiontime" | "priority" | "completed" | "archived" | "createdat" | "lastcompletedat" | "modifiedat";
export type tasksCreationAttributes = Optional<tasksAttributes, tasksOptionalAttributes>;

export class tasks extends Model<tasksAttributes, tasksCreationAttributes> implements tasksAttributes {
  taskid!: number;
  parentid?: number;
  title!: string;
  description?: string;
  totaltimeestimated?: number;
  remainingtimeestimated?: number;
  prefferedsessiontime?: number;
  priority?: number;
  completed?: number;
  archived?: number;
  createdat?: number;
  lastcompletedat?: number;
  modifiedat?: number;

  // tasks hasMany activities via parentid
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
  // tasks hasMany plans via parentid
  plans!: plans[];
  getPlans!: Sequelize.HasManyGetAssociationsMixin<plans>;
  setPlans!: Sequelize.HasManySetAssociationsMixin<plans, plansId>;
  addPlan!: Sequelize.HasManyAddAssociationMixin<plans, plansId>;
  addPlans!: Sequelize.HasManyAddAssociationsMixin<plans, plansId>;
  createPlan!: Sequelize.HasManyCreateAssociationMixin<plans>;
  removePlan!: Sequelize.HasManyRemoveAssociationMixin<plans, plansId>;
  removePlans!: Sequelize.HasManyRemoveAssociationsMixin<plans, plansId>;
  hasPlan!: Sequelize.HasManyHasAssociationMixin<plans, plansId>;
  hasPlans!: Sequelize.HasManyHasAssociationsMixin<plans, plansId>;
  countPlans!: Sequelize.HasManyCountAssociationsMixin;
  // tasks belongsTo tasks via parentid
  parent!: tasks;
  getParent!: Sequelize.BelongsToGetAssociationMixin<tasks>;
  setParent!: Sequelize.BelongsToSetAssociationMixin<tasks, tasksId>;
  createParent!: Sequelize.BelongsToCreateAssociationMixin<tasks>;

  static initModel(sequelize: Sequelize.Sequelize): typeof tasks {
    return tasks.init({
    taskid: {
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
    title: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    totaltimeestimated: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    remainingtimeestimated: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    prefferedsessiontime: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    priority: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    completed: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    archived: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    createdat: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    lastcompletedat: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    modifiedat: {
      type: DataTypes.INTEGER,
      allowNull: true
    }
  }, {
    sequelize,
    tableName: 'tasks',
    schema: 'public',
    timestamps: false,
    indexes: [
      {
        name: "tasks_pkey",
        unique: true,
        fields: [
          { name: "taskid" },
        ]
      },
    ]
  });
  }
}
