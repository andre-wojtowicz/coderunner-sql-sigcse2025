#### PostgreSQL-shared

A teacher working on a new question has to provide a standard question description, an example answer for validation and test cases. The basic setup of a test case requires code in the **Extra template data** section which uses Python functions provided by the template. Verification of a test case is done by textual output comparison. When a database engine reports an error it is displayed to the student.

The following subsections briefly describe how a test case is prepared depending on the question type. This question template automatically creates a temporary database on a shared server and cleans up the environment at the end of evaluation. These general guidelines use Python code and can be customized by the teacher accordingly to the course requirements.

#### DQL Question Type

This type of question uses the `SELECT` command to extract data from a database. In **Extra template data** section of a test case, firstly, a database is filled with tables, data, etc.; secondly, a student's answer is invoked with output printed on the standard output. Since validation is done in a textual way, the teacher should either a) explicitly put in the question description what columns should the student use to sort results by `ORDER BY` clause; or b) configure the script to sort rows in a pre-processing step before printing to the standard output. See sample code below:

```python
__db_code__ = r'''
-- database init commands e.g. CREATE TABLE, INSERT etc.
-- ...
'''

invoke_cursor_sql(__db_code__)
print(invoke_cursor_sql(__student_answer__))
```

#### DDL/DML Question Type

This type of question checks a student's ability to modify a database, e.g. with `CREATE`, `INSERT` etc. commands. In **Extra template data** section of a test case, firstly, a database is filled with tables, data etc.; secondly, a student's answer is invoked; thirdly, a verification `SELECT` query is invoked with output printed on standard output. See sample code below:

```python
__db_code__ = r'''
-- database init commands e.g. CREATE TABLE, INSERT etc.
-- ...
'''

__testcode__ = r'''
-- statement checking database structure e.g. SELECT data about 
-- columns in a table using INFORMATION_SCHEMA view; test code can be
-- provided here or in 'Test code X' section of a test case
-- ...
'''

invoke_cursor_sql(__db_code__)
invoke_cursor_sql(__student_answer__)
print(invoke_cursor_sql(__testcode__))
```

#### Optional Grammar Check

If a question has to be solved with a specific method, then a parsing tree analysis of an input SQL statement is possible. Firstly, in **Expected output** section of a test case the teacher provides what elements of the PL/SQL grammar and tokens must be detected in a student's statement, e.g. it can be `group_by_clause` with `HAVING`, respectively, as presented below:

> Matched grammar elements: group_by_clause

> Matched tokens: HAVING

Secondly, in **Extra template data** section the teacher states which elements of the grammar and tokens have to be detected in the student's statement. Those two lists can have more elements than those provided in **Expected output** because the teacher e.g. can strictly forbid solving this particular question with the use of a `LIMIT` clause. Moreover, if the teacher e.g. wants to prevent putting multiple independent `SELECT` statements, then the `unit_statements` grammar element can be detected. If any of the explicitly provided elements will be detected, then the output text will not match with those provided in **Expected output** section. See sample code below:

```python
print(check_query_grammar_elements(['limit_clause', 'unit_statements', 'group_by_clause']))
print(check_query_tokens(['HAVING']))
```

This kind of heuristic test case is helpful when students practice elementary SQL statements and the teacher wants to check if they know how to solve different problems only by using a given method. Some limitations like multiple SQL clauses, set-theory operations etc. can be provided in this test case but the teacher must be aware that a skilled student can hypothetically bypass these restrictions with a well refined SQL statement. On the other hand, introductory courses assume no prior student knowledge on SQL and even if a student is able to construct such a SQL statement then it is very probable that the skill level present exceeds the course level anyway. Hence deviations of this kind have a very low probability of occurrence and our in our evaluation, where we manually double-checked students' answers, we did not notice cheating in this way. Nevertheless, more sophisticated analysis of the parse tree can be done programmatically here by the teacher if needed.

[Here](https://github.com/datacamp/antlr-plsql/blob/d3915a1a3f1f7434b9e8e863367dbfbc1e062acc/antlr_plsql/plsql.g4) you can see what the SQL grammar used looks like. Note that the template uses the names of grammar elements in lowercase letters and multiple independet `SELECT` statements are returned in `check_query_grammar_elements()` by non-standard `unit_statements`.

Cheat sheet for `check_query_grammar_elements([...])`:

| name | meaning |
| ----- | --------- |
| `'unit_statements'`             | multiple independent SQL queries |
| `'limit_clause'`                | `LIMIT` |
| `'join_clause'`                 | table join |
| `'subquery'`                    | subquery |
| `'aggregate_windowed_function'` | aggregate function |
| `'group_by_clause'`             | grouping (`GROUP BY`) |
| `'isexpr', 'is_part'`           | `IS` part for e.g. `IS NULL` |
| `'order_by_clause'`             | sorting |
| `'join_type'`                   | join type (e.g. inner or outer) |

#### Other types of assignments

Above we described DQL, DML and DDL queries but our solution is able to cover problems where a student has to write e.g. SQL script, stored procedures, functions etc., as long as created objects persist within a temporary database. In the above examples we used `invoke_cursor_sql(...)` Python function which uses a cursor to process output data, hence we can programmatically investigate structurized tabular output. It is possible to directly use the `psql` command-line tool with `invoke_commandline_sql(...)` but note that in this approach, the output is strictly textual and harder to investigate. There are also multiple requirements for correct usage of `psql`.
