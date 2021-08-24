# SQL Functions

#### Introduction
In Module 7, we learn about SQL functions. This paper explains when one would use a SQL User Defined Function (UDF). It also discusses the differences between Scalar, In-Line, and Multi-Statement functions.  

#### SQL User Defined Functions
There are many built-in functions in SQL Server, but users can also write their own custom functions or UDFs. You can do this to make coding more efficient and avoid writing out the same code time after time. Sometimes you cannot find a system function that meets your needs, then that is when UDFs can be the solution. 

#### Scalar, In-Line, and Multi-Statement Functions
There are different kinds of UDFs. 

A scalar function returns a single value (e.g. text, number, date). It cannot update data, but can call other functions.

An in-line function returns a single set of rows. Inline functions usually perform better than multi-statement functions.

A multi-statement function returns a table of data. You can include multiple select statements and other complexities in a multi-statement function.

#### Conclusion
In essence, a function accepts inputs in the form of parameters and returns a value. Depending on the type of task you would like to perform, you can choose functions ranging from simple to complex. Functions are very useful for processing and manipulating data. If you cannot find a built-in function that works, you also have the ability to create your own user defined function. These functions make the database development process easier and help to avoid rewriting the same code again.
