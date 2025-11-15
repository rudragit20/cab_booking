create database cb;
use cb;

#Customer Table
create table Customers(CustomerID int primary key, Name varchar(50), Email varchar (50), RegistrationDate date);

#Drivers Table
create table Drivers(DriverID int primary key, Name varchar(50), JoinDate date); 

#Cabs Table
create table Cabs(CabID int primary key, DriverID int, VehicleType varchar(50), PlateNumber varchar(20), foreign key(DriverID)
references Drivers(DriverID));

#Bookings Table
create table Bookings(BookingID int primary key, CustomerID int, CabID int, BookingDate datetime, Status varchar(20),
PickupLocation varchar(100), DropoffLocation varchar(100), foreign key(CustomerID) references Customers(CustomerID),
foreign key(CabID) references Cabs(CabID));

#TripDetails Table
create table TripDetails(TripID int primary key, BookingID int, StartTime datetime, EndTime datetime, DistanceKM float, Fare float,
foreign key (BookingID) references Bookings(BookingID));

#Feedback Table
create table Feedback(FeedbackID int primary key, BookingID int, Rating float, Comments text, FeedbackDate date,
foreign key (BookingID) references Bookings(BookingID));

#Inserting values into tables

insert into Customers values(1,'Alice Johnson','alice@example.com','2023-01-15'),(2,'Bob Smith','bob@emaple.com','2023-02-20'),
(3,'Charlie Brown','charlie@emaple.com','2023-03-05'),(4,'Diana Prince','diana@example.com','2023-04-10');
select * from Customers;

insert into Drivers values(101,'John Driver','2025-05-10'),(102,'Linda Miles','2022-07-25'),(103,'Kevin Road','2023-01-01'),
(104,'Sandra Swift','2022-11-11');
select * from Drivers;

insert into Cabs value(1001,101,'Sedan','ABC1234'),(1002,102,'SUV','XYZ5678'),(1003,103,'SUV','PQR3456'),(1004,104,'SUV','PQR3456');
select * from Cabs;

insert into Bookings values(201,1,1001,'2024-10-01 8:30:00','Completed','Downtown','Airport'),(202,2,1002,'2024-10-02 09:00:00',
'Completed','Mall','University'),(203,3,1003,'2024-10-03 10:15:00','Cancelled','Station','Downtown'),(204,4,1004,'2024-10-05 18:45:00',
'Completed','Downtown','Airport'),(206,2,1001,'2024-10-06 07:20:00','Cancelled','University','Mall');
select * from Bookings;

insert into TripDetails values(301,201,'2024-10-01 08:45:00','2024-10-01 09:20:00',18.5,250.00),(302,202,'2024-10-02 18:50:00',
'2024-10-05 19:30:00',20.0,270.0),(303,203,'2024-10-04 14:10:00','2024-10-04 14:40:00',10.0,150.00),(304,204,'2024-10-05 18:50:00',
'2024-10-05 19:30:00',20.0,270.0);
select * from TripDetails;

insert into Feedback values(401,201,4.5,'Smooth Ride','2024-10-01'),(402,203,3.0,'Driver was late','2024-10-02'),(403,203,5.0,
'Excellent service','2024-10-04'),(404,206,2.5,'Cab was not clean','2024-10-05');
select * from Feedback;

#Analysis of the data

#Customer & Booking analysis Completedbookings
select c.CustomerID, c.Name, count(*) as CompletedBookings 
from Customers c join Bookings b on c.CustomerID=b.CustomerID 
where b.Status='Completed' group by c.CustomerID, c.Name order by CompletedBookings desc;

#Customer & Booking analysis Incompletedbookings
select c.CustomerID, c.Name, count(*) as IncompletedBookings 
from Customers c join Bookings b on c.CustomerID=b.CustomerID 
where b.Status='Cancelled' group by c.CustomerID, c.Name order by IncompletedBookings desc;

#Customers with more than30% cancellation
select CustomerID, sum(case when Status='Cancelled' then 1 else 0 end) as Cancelled,
count(*) as Total, round(100.0*sum(case when Status='Cancelled' then 1 else 0 end)/count(*),2)
as CancellationRate from Bookings group by CustomerID having CancellationRate>30;

#Busiest day of the week
select date_format(BookingDate,'%W') as DayofWeek, count(*) as TotalBookings from Bookings
group by date_format(BookingDate,'%W') order by TotalBookings desc;

#Drivers with average rating<3 in last 3 months
select d.DriverID, d.Name, avg(f.Rating) as AvgRating from Drivers d
join Cabs c on d.DriverID=c.DriverID join Bookings b on c.CabID=b.CabID
join Feedback f on b.BookingID=f.BookingID where f.Rating is not null and
f.FeedbackDate>= date_add(BookingDate,interval -3 month) group by d.DriverID, d.Name
having avg(f.Rating)>3.0;

#Top 5 drivers by Total distance covered
select d.DriverID, d.Name, avg(f.Rating) as AvgRating from Drivers d
join Cabs c on d.DriverID=c.DriverID
join Bookings b on c.CabID=b.CabID
join Feedback f on b.BookingID=f.BookingID
where f.Rating is not null and f.FeedbackDate>=(CURDATE() - INTERVAL 3 MONTH)
group by d.DriverID, d.Name having avg(f.Rating)<3.0;