import type { Sequelize } from "sequelize";
import { activities as _activities } from "./activities";
import type { activitiesAttributes, activitiesCreationAttributes } from "./activities";
import { plans as _plans } from "./plans";
import type { plansAttributes, plansCreationAttributes } from "./plans";
import { tasks as _tasks } from "./tasks";
import type { tasksAttributes, tasksCreationAttributes } from "./tasks";

export {
  _activities as activities,
  _plans as plans,
  _tasks as tasks,
};

export type {
  activitiesAttributes,
  activitiesCreationAttributes,
  plansAttributes,
  plansCreationAttributes,
  tasksAttributes,
  tasksCreationAttributes,
};

export function initModels(sequelize: Sequelize) {
  const activities = _activities.initModel(sequelize);
  const plans = _plans.initModel(sequelize);
  const tasks = _tasks.initModel(sequelize);

  activities.belongsTo(plans, { as: "plan", foreignKey: "planid"});
  plans.hasMany(activities, { as: "activities", foreignKey: "planid"});
  activities.belongsTo(tasks, { as: "parent", foreignKey: "parentid"});
  tasks.hasMany(activities, { as: "activities", foreignKey: "parentid"});
  plans.belongsTo(tasks, { as: "parent", foreignKey: "parentid"});
  tasks.hasMany(plans, { as: "plans", foreignKey: "parentid"});
  tasks.belongsTo(tasks, { as: "parent", foreignKey: "parentid"});
  tasks.hasMany(tasks, { as: "tasks", foreignKey: "parentid"});

  return {
    activities: activities,
    plans: plans,
    tasks: tasks,
  };
}
