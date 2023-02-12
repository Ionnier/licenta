import { Sequelize } from 'sequelize'
import { initModels, activities, plans, tasks } from "../models/init-models";

export let models: {
    activities: typeof activities,
    plans: typeof plans,
    tasks: typeof tasks,
}

export function initDatabase() {
    const sequelize = new Sequelize(process.env.DATABASE_URL || "");
    models = initModels(sequelize);
}

