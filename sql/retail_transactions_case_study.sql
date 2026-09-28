/* SQL case study Basic*/

use [Retail_data]

/*Data Preperaton and Understanding*/

/*Question 1 */

select count (*) as Total_Rows,Table_Name = 'customer_Table'
from [dbo].[Customer]
union
select count (*) as Total_Rows,Table_Name = 'prod_cat_info_Table'
from [dbo].[prod_cat_info]
union
select count (*) as Total_Rows,Table_Name = 'Transactions_Table'
from [dbo].[Transactions];

/* Q1. END */

/*Question 2 */

select count (distinct transaction_id) as COUNT
from [dbo].[Transactions]
where Rate < 0;

/* Q2. END */

/*Question 3 */

select convert(date,tran_date,105) as Transaction_date
from [dbo].[Transactions];

/* Q3. END */

/*Question 4 */

select
datediff(YEAR,MIN(convert(date,tran_date,105)),max(convert(date,tran_date,105))) as Diff_years,
datediff(month,MIN(convert(date,tran_date,105)),max(convert(date,tran_date,105))) as Diff_month,
datediff(day,MIN(convert(date,tran_date,105)),max(convert(date,tran_date,105))) as Diff_date
from[dbo].[Transactions];

/* Q4. END */

/*Question 5 */

select prod_cat,prod_subcat
from [dbo].[prod_cat_info]
where prod_subcat = 'DIY';

/* Q5. END */

/*DATA ANAlYSIS*/

/*Question 1 */
select top 1 Store_type,
count(transaction_id) as count_store
from [dbo].[Transactions]
group by Store_type
order by count_store desc;

/* Q1. END */

/*Question 2 */

select Gender,
count(Gender) as Gender_count
from [dbo].[Customer]
where Gender is not null
group by Gender;

/* Q2. END */

/*Question 3 */

select top 1 city_code,
count (distinct customer_id) as Count_customers
from [dbo].[Customer]
where city_code is not null
group by city_code
order by Count_customers desc;

/* Q3. END */

/*Question 4 */

select prod_cat ,count (prod_subcat) as Count_subcat
from [dbo].[prod_cat_info] 
where prod_cat = 'Books'
group by prod_cat;

/* Q4. END */

/*Question 5 */

select a.prod_cat_code, b.prod_cat,max (CONVERT(int,Qty)) as Count_qty
from [dbo].[Transactions] as a
join [dbo].[prod_cat_info] as b
on a.prod_cat_code = b.prod_cat_code
group by a.prod_cat_code,b.prod_cat
order by Count_qty desc;


/* Q5. END */

/*Question 6 */

select SUM(cast(total_amt as float)) as revenue
from [dbo].[prod_cat_info] as a
join [dbo].[Transactions]as b
on a.prod_cat_code = b.prod_cat_code 
and a.prod_sub_cat_code = b.prod_subcat_code
where prod_cat = ('books') or
      prod_cat = ('electronics');
 
/* Q6. END */

/*Question 7 */

select count(*) as total_cust
from (
         select cust_id,COUNT(distinct cust_id) as count_cusid
         from [dbo].[Transactions]
          where Qty > 0
          group by cust_id
          having count(distinct transaction_id) > 10) as X;

/* Q7. END */

/*Question 8 */

select sum(total_amt) as Combined_revenue
from(
        select a.Store_type,b.prod_cat,total_amt
        from [dbo].[Transactions] as a
         join [dbo].[prod_cat_info] as b
         on a.prod_cat_code = b.prod_cat_code and a.prod_subcat_code = b.prod_sub_cat_code
         where (prod_cat = 'electronics' or prod_cat ='clothing')and 
         Store_type = 'Flagship store'
)as x;

/* Q8. END */

/*Question 9 */  

select x.prod_subcat,sum(total_amt) as Total_Revenue
from (select c.Gender,b.prod_cat,b.prod_subcat,A.total_amt
       from [dbo].[Transactions] as A
       join [dbo].[prod_cat_info] as B
       on A.prod_cat_code=B.prod_cat_code and A.prod_subcat_code=B.prod_sub_cat_code
       join [dbo].[Customer] as c
       on A.cust_id =C.customer_Id
       where Gender = 'M' and prod_cat = 'Electronics') as X
group by X.prod_subcat;

/* Q9. END */

/*Question 10 */  

select TB_2.prod_subcat,TB_1.Percentage_sales,TB_2.Percentage_returns
from
     (select top 5 b.prod_subcat,((SUM(total_amt))/(select sum(total_amt) as total_sales from [dbo].[Transactions] where QTY >0)) as Percentage_sales
      from [dbo].[Transactions] as A
      join [dbo].[prod_cat_info] as B
      on A.prod_cat_code=b.prod_cat_code and A.prod_subcat_code =B.prod_sub_cat_code
      where total_amt > 0 
      group by B.prod_subcat
      order by Percentage_sales desc) as TB_1
join
(select b.prod_subcat,((SUM(total_amt))/(select SUM(total_amt) as Total_returns from [dbo].[Transactions] where Qty < 0)) as Percentage_returns
from [dbo].[Transactions] as A
join [dbo].[prod_cat_info] as B
on A.prod_cat_code=b.prod_cat_code and A.prod_subcat_code =B.prod_sub_cat_code
where total_amt < 0
group by B.prod_subcat) as TB_2
on TB_1.prod_subcat = TB_2.prod_subcat;

/* Q10. END */

/*Question 11 */ 

select * 
from 
(select customer_id, DATEDIFF(year,DOB,Max_date) as age,revenue
from
(select B.customer_Id,B.DOB, MAX(convert(date,tran_date,105)) as Max_date,sum(cast(total_amt as float)) as revenue
from [dbo].[Transactions] as A
join [dbo].[Customer] as B
on A.cust_id = B.customer_Id
group by  B.customer_Id,B.DOB) as X
where 25 < DATEDIFF(year,DOB,Max_date) and  35 > DATEDIFF(year,DOB,Max_date))as Y

join

(select cust_id, convert(date,Tran_date,105) as tran_date
from [dbo].[Transactions]
group by cust_id,convert(date,Tran_date,105)
having convert(date,Tran_date,105) >= (select DATEADD(day, -30 ,max(convert(date,Tran_date,105)))as cuttoff_date 
                                       from [dbo].[Transactions])) as Z
                                        on Y.customer_Id=Z.cust_id;

/* Q11. END */

/*Question 12*/

select top 1 x.prod_cat_code,sum(returns)as total_returns 
from (select convert(date,tran_date,105) as Trans_dates,prod_cat_code,SUM(convert(int,qty)) as returns
       from [dbo].[Transactions] 
       where Qty < 0
       group by prod_cat_code,convert(date,tran_date,105)
       having convert(date,tran_date,105) >(select dateadd(day,-90,MAX(convert(date,tran_date,105)))
                                            from [dbo].[Transactions]))as X
                                            group by x.prod_cat_code
                                            order by total_returns;

/* Q12. END */

/*Question 13*/	

select  Sum(total_amt)as sales_amount,Store_type,sum(convert(int,qty)) as qty_sold
from [dbo].[Transactions]
where Qty > 0
group by Store_type
order by sales_amount desc,qty_sold desc;

/* Q13. END */

/*Question 14*/

select AVG(total_amt) as AVG_Revenue,prod_cat_code
from [dbo].[Transactions]
where Qty > 0
group by prod_cat_code
having AVG(total_amt) >= (select AVG(total_amt) as AVG_Revenue
                         from [dbo].[Transactions]
                         where Qty > 0);

/* Q14. END */

/*Question 15*/

select sum(total_amt) as Revenue,AVG(Total_amt) as average,prod_subcat_code
from[dbo].[Transactions]
where qty > 0 and prod_subcat_code in (select top 5 prod_cat_code
                                        from [dbo].[Transactions]
                                        where Qty >0
                                        group by prod_cat_code
                                        order by sum(convert(int,qty)) desc)
group by prod_subcat_code;

/* Q15. END */




