create table if not exists ride(id int primary key, name varchar(100), start datetime, end datetime, miles int, regionloc varchar(50));

create table if not exists user(id int primary key, name varchar(100));

create table if not exists rider(id int primary key, rideid int, userid int);
