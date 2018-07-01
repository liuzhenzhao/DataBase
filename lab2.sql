create table Dept(
    No int not null,
    Name varchar(30) not null,
    constraint Dept_PRIMARYKEY_CONS primary key(No));
insert into Dept values(001,'计算机科学与技术学院');
create table Reader(
	Account varchar(10) not null,
    Password varchar(20) not null,
    Name     varchar(20) not null,
    DeptNo   int not null,
    Tel      varchar(20) not null,
    Authority int default 1,
    constraint Reader_PRIMARYKEY_CONS primary key(Account),
    constraint Reader_FOREIGNKEY_CONS foreign key(DeptNo) references Dept on delete cascade
	);
insert into Reader values('U201514301','123456','刘祯钊',001,'15271858331',1);
create table Book(
    No Number(9,0) not null,
    indexNo varchar(20) not null,
    Title varchar(30) not null,
    Location varchar(30) not null,
    State varchar(10) not null,
    Author varchar(20) not null,
    pub varchar(40) not null,
    Year int not null,
    Month int not null,
    constraint Book_PRIMARYKEY_CONS primary key(No)
    );
insert into Book values(1,'TP321-451','大学计算机基础','主图2楼B区',
	'在架上','江代有','中国铁道出版社',2006,8);
insert into Book values(2,'TP181-W8','机器学习','外文图书阅览室',
'在架上','Simon Rogers','Boca Raton',2012,2);
create table Ticket(
    ReaderAccount varchar(10) not null,
    BookNo Number(9,0) not null,
    Total Number(4,1),
    RealPay Number(4,1),
    constraint Ticket_PRIMARYKEY_CONS primary key(ReaderAccount,BookNo));
create table Borrow(
    BookNo Number(9,0) not null,
    ReaderAccount varchar(10) not null,
    ReturnDate Date not null,
    Reborrow int default 0,
    constraint Borrow_PRIMARYKEY_CONS primary key(BookNo,ReaderAccount,ReturnDate),
    constraint Borrow_FOREINGKEY_CONS1 foreign key(ReaderAccount) references Reader on delete cascade,
    constraint Borrow_FOREINGKEY_CONS2 foreign key(BookNo) references Book on delete cascade
    );










--1 (计算机学院)","2 (自动化学院)","3 (光电学院)","4 (电信学院)","5 (电气学院)","6 (机械学院)
/*update Borrow set (reborrow,Returndate)=(select 1,Returndate - interval '90' day from dual)
                where not exists 
	       (select * from Borrow t1,Book t2
               where t1.BookNo=t2.No
               and   t1.Reborrow=1)
               and   borrow.BOOKNO=1;*/
--select * from borrow;
--update borrow set reborrow=(select 0 from dual);
--update borrow set (reborrow,returndate)=(0,select Returndate + interval '30' day from dual);
--select Returndate + interval '30' day from dual;
--update Borrow set (reborrow,Returndate)=(select 1,Returndate + interval '90' day from dual)                 where not exists 	       (select * from Borrow t1,Book t2                where t1.BookNo=t2.No                and   t1.Reborrow=1)                and   borrow.BOOKNO=1
--select No,indexNo,Location,State,Title,Author from Book t where t.Title='机器学习' and t.Author='Simon Rogers' and t.pub='Boca Raton'
/*select * from BOOK t1,READER t2
                                                                           where t1.NO=2 and t2.ACCOUNT='U201514301';*/
--select SYSDATE + interval '30' day,0 from dual;
/*insert into Borrow(BOOKNO,READERACCOUNT,RETURNDATE,REBORROW) select t1.NO as seqno,t2.ACCOUNT as Account,
                                                                      SYSDATE + interval '30' day,0
                                                                      from BOOK t1,READER t2,dual t3
                                                                           where t1.NO=2 and t2.ACCOUNT='U201514301'
                                                                            and t1.STATE='在架上';*/
--drop trigger trig_BOOK;
create or replace trigger trig_BOOK
     after insert on BORROW
     for each row
     declare
        tempNo BORROW.BOOKNO%TYPE;
     begin
       tempNo :=:new.BOOKNO;
       update BOOK set BOOK.STATE='被借阅' where BOOK.NO=tempNo;
     end;
--update BOOK set BOOK.STATE='在架上' where BOOK.NO=2;
create   table   test(id number,cur_time   date);
create or replace trigger tri_test_id
 before insert on test   --test 是表名
    for each row
   declare
     nextid number;
   begin
     IF :new.id IS NULL or :new.id=0 THEN --id是列名
       select test_sequence.nextval --SEQ_ID正是刚才创建的
      into nextid
      from sys.dual;
      :new.id:=nextid;
    end if;
   end tri_test_id;
   /
create or replace trigger tri_test_id  
  before insert on test   --test 是表名  
  for each row  
declare  
  nextid number;  
begin  
  IF :new.id IS NULL or :new.id=0 THEN --id是列名  
    select test_sequence.nextval --SEQ_ID正是刚才创建的  
    into nextid  
    from sys.dual;  
    :new.id:=nextid;  
  end if;  
end tri_test_id;
create   or   replace   procedure   proc_test   as    
       begin    
       insert   into   test(cur_time)   values(sysdate);    
       end;    
       /  

     declare job1 number;  
     begin  
        sys.dbms_job.submit(job1,'proc_test;',sysdate,'sysdate+1/1440');--每天1440分钟，即一分钟运行test过程一次  
    end;
    / 
    begin
　　 dbms_job.run(:job1);
　　end;
　　/


////////////////////
create or replace procedure update_ticket as
--declare
  --  tempCount Number;
	begin
	/*select count(*) into tempCount from Borrow bb,Ticket tt
	                where bb.ReaderAccount=tt.ReaderAccount
	                and bb.BookNo=tt.BookNo;*/
	create table cache(BookNo Number(9,0) not null,ReaderAccount varchar(10) not null,
		ReturnDate Date not null,primary key(BookNo,ReaderAccount)
		);--cache中存放逾期未还书记录
	insert into cache(BookNo,ReaderAccount,ReturnDate) 
		        select t1.BookNo,t1.ReaderAccount,t1.ReturnDate 
		        from Borrow t1,dual t2 
		        where t1.ReturnDate<SYSDATE;
    insert into Ticket(ReaderAccount,BookNo,Total,RealPay) 
                select t1.ReaderAccount,t1.BookNo,0.5*ceil(sysdate-t1.returndate),0 
                from cache t1,dual--找到在cahce中但不在Ticket中的表项插入到Ticket中
           		where not exists(
           	     select * from t1,Ticket t2
           	     where t1.ReaderAccount=t2.ReaderAccount
           	     and t1.BookNo=t2.BookNo);
    update Ticket t1 set t1.TOTAL=(select 0.5*ceil(sysdate-t2.returndate)
    	                      from Borrow t2,dual
    	                      where exists(
    	                      	select * from borrow t4,Ticket t3
           	     				where t4.ReaderAccount=t3.ReaderAccount
           	     				and t4.BookNo=t3.BookNo
                                                and t2.BOOKNO=t4.BOOKNO
                                                and t2.READERACCOUNT=t4.READERACCOUNT
                                                and t1.READERACCOUNT=t3.READERACCOUNT
                                                and t1.BOOKNO=t3.BOOKNO)
                                                );
	/*IF tempCount=0 THEN
    insert into Ticket(ReaderAccount,BookNo,Total,RealPay) 
    	select t1.ReaderAccount,t1.BookNo,0.5*ceil(sysdate-returndate) as Total,0 as RealPay 
    	                from Borrow t1,dual t2
    	                where ReturnDate<SYSDATE;
    ELSE
    update Ticket t set Total=(select 0.5*ceil(sysdate-returndate) 
    	                     from Borrow b,dual d where b.Returndate<SYSDATE
    	                                          and t.ReaderAccount=b.ReaderAccount
    	                                          and t.BookNo=b.BookNo);
    END IF;*/
	end;

	declare job2 number;  
     begin  
        sys.dbms_job.submit(job2,'update_ticket;',sysdate,'sysdate+1/1440');--每天1440分钟，即一分钟运行test过程一次  
    end;
    / 
    begin
　　 dbms_job.run(:job2);
　　end;
　　/