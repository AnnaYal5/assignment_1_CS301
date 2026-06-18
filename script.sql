create table memberships ( --Таблиця типів підписок--
	membership_id serial primary key,
	name varchar(50) not null,
	price decimal(10, 2) not null
);

create table members ( --Таблиця клієнтів, яка пов'язана з підписками--
	member_id serial primary key,
    full_name varchar(100) not null,
    email varchar(100),
    membership_id int references memberships(membership_id) --стоврення зовнішнього ключа щоб зв'язати таблиці--
);

create table coaches ( --Таблиця тренерів--
	coach_id serial primary key,
	name varchar(50) not null,
	specialization varchar(100) not null
);

create table classes ( --таблиця розкладу занять, яка пов'язана з тренером--
	class_id serial primary key,
	name varchar(100) not null,
	class_date date not null,
	coach_id int references coaches(coach_id)
);

create table bookings ( --Таблиця бронювань тренувань, яка пов'язана з клієнтом та тренуванням--
	booking_id serial primary key,
	member_id int references members(member_id),
	class_id int references classes(class_id),
	booking_date date not null
);

insert into memberships (name, price) values
	('Superpass', 1650.00),
	('Multipass', 2200.00),
	('Smartpass', 1100.00),
	('Dailypass', 540.00),
	('Teenpass', 1000.00);

insert into members (full_name, email, membership_id) values
	('Олександр Коваленко', 'alex@email.com', 2),
	('Марія Петренко', 'maria@email.com', 1),
	('Іван Бондар', 'ivan@email.com', 3),
	('Олена Шевченко', 'olena@email.com', 5),
	('Дмитро Кравченко', 'dima@email.com', 1);

insert into coaches (name, specialization) values
	('Дмитро','CrossFit'),
	('Дарина','Stretching'),
	('Олена','Upper Body'),
	('Карина','Pilates'),
	('Катерина','Body Tone');

 insert into classes (name, class_date, coach_id) values
  	('CrossFit', '2026-06-20', 1),
  	('Stretching', '2026-06-20', 2),
  	('Upper Body', '2026-06-21', 3),
  	('Pilates', '2026-06-23', 4),
  	('Body Tone', '2026-06-23', 5);

 insert into bookings (member_id, class_id, booking_date) values
  	(1,1,'2026-06-20'),
   	(1,2,'2026-06-20'),
  	(2,1,'2026-06-21'),
  	(3,3,'2026-06-21'),
  	(4,4,'2026-06-23'),
  	(4,5,'2026-06-23'),
  	(2,1,'2026-06-20');


  --Створюю CTE та віконні функції row_number(кількість занять для клієнта),count(кількість людей на занятті)
with club_analytics as (
    select
        b.booking_date as booking_date,
        m.full_name as member_name,
        cl.name as class_name,
        c.name as coach_name,
        ms.name as membership_name,
        ms.price as membership_price,
        row_number() over(partition by b.member_id order by b.booking_date) as visit_count,
        count(b.booking_id) over(partition by b.class_id) as total_people
    from bookings b
    join members m on b.member_id = m.member_id
    join classes cl on b.class_id = cl.class_id
    join coaches c on cl.coach_id = c.coach_id
    join memberships ms on m.membership_id = ms.membership_id
)

--Підписка дорожча за 1100.00---
select
    booking_date,
    member_name,
    class_name,
    coach_name,
    membership_name,
    membership_price,
    visit_count,
    total_people,
    'Преміум-сегмент' as "category"
from club_analytics
where membership_price > 1100.00

union all

--Підписка дешевша за 1100.00---
select
    booking_date,
    member_name,
    class_name,
    coach_name,
    membership_name,
    membership_price,
    visit_count,
    total_people,
    'Базовий-сегмент' as "category"
from club_analytics
where membership_price <= 1100.00

order by booking_date, class_name;