from cassandra.cluster import Cluster
cluster = Cluster()
session = cluster.connect(['10.60.8.23','10.60.8.24'])

session.execute("""
insert into users (lastname, age, city, email, firstname) values ('Jones', 35, 'Austin', 'bob@example.com', 'Bob')

""")

result = session.execute("select * from users where lastname='Jones' ")[0]
print result.firstname, result.age