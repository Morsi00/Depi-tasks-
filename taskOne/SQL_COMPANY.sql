use company
go

Create table company.employees(
SSN int primary key,
First_name nvarchar(24) NOT NULL,
Last_name nvarchar(24),
Birth_date date ,
Gender varchar(1),
superviser int ,
DNUM int

 )


 Create table company.department(
 DNUM int primary key ,
 Dname nvarchar(24),
 hiri_data date ,
 SSN_fk int 
 )

 
 Create table company.project (
 PNUM int primary key ,
 pname nvarchar(24),
 Plocation nvarchar (24),
 DNUM int ,
 
 )
 alter table company.project add  unique(pname)
 

 create table company.dependent(
 Nname  nvarchar(24),
 SSN   int ,
 birth_date date ,
 Gender  varchar(1)
 primary key (Nname,SSN)
 )
 alter table company.dependent  add default 'm' for Gender
 alter table company.dependent  add  CHECK (Gender IN ('m', 'f'))
 Create table company.department_location(
 Dlocation nvarchar(24),
 DNUM int
 primary key(Dlocation,DNUM)
 )
  Create table company.employee_project(
  SSN   int ,
 DNUM int
 primary key(SSN,DNUM)
 )
 alter table company.employees add foreign key(DNUM) references company.department(DNUM)
 alter table company.employees add foreign key(superviser) references company.employees(SSN)


  alter table company.employee_project  add foreign key(DNUM) references company.project(pNUM)
 alter table company.employee_project  add foreign key(ssn) references company.employees(ssn)



 alter table company.department add foreign key(SSN_fk) references company.employees(SSN)
 alter table company.department_location add foreign key(DNUM) references company.department(DNUM)
 alter table company.project  add foreign key(DNUM) references company.department(DNUM)


  alter table company.dependent  add foreign key(SSN) references company.employees(ssn) on delete CASCADE 

  alter table company.project add start_date date 


  alter table company.dependent drop column birth_date
  select * from company.department
