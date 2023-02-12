drop table if exists Activities;
drop table if exists Plans;
drop table if exists Tasks;

create table Tasks(
	taskId SERIAL PRIMARY KEY NOT NULL, 
	parentId INTEGER, 
	title TEXT NOT NULL, 
	description TEXT, 
	totalTimeEstimated INT, 
	remainingTimeEstimated INT,
	prefferedSessionTime INT, 
 	priority INT, 
	completed INT, 
	archived INT, 
 	createdAt INT, 
	lastCompletedAt INT, 
	modifiedAt INT, 
	foreign key(parentId) references tasks(taskId) on delete cascade 
);

create table Plans( 
	 planId SERIAL PRIMARY KEY, 
	 parentId INTEGER, 
	 name TEXT, 
	 startsAt INT, 
	 endsAt INT, 
	 createdAt INT, 
	 modifiedAt INT, 
	 completed INT, 
	 foreign key(parentId) references Tasks(taskId) on delete set null 
) 

create table Activities(
	activityId serial PRIMARY KEY,
	parentId INTEGER,
	planId INTEGER,
	comment TEXT,
	startedAt INT,
	timeSpent INT,
	createdAt INT,
	modifiedAt INT,
	foreign key(parentId) references Tasks(taskId) on delete cascade,
	foreign key(planId) references Plans(planId) on delete cascade
);
