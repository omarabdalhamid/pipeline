
nohup docker exec -t bb3abb9e4e_odoo13_1 bash -c "odoo -d unit_test2 --db_host  db -w odoo --test-enable --test-tags  'standard,test_account_asset'" > unit_test.log  & timeout 180s tail -f unit_test.log 

kill -9 $(ps aux |grep bb3abb9e4e_odoo13_1)
