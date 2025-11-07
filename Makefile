.PHONY: ping setup deploy check nginx-reload

ping:
	ansible all -m ping

setup:
	ansible-playbook playbooks/site.yml --tags "common,python,app,gunicorn,nginx"

deploy:
	ansible-playbook playbooks/site.yml --tags "app,gunicorn,nginx"

check:
	ansible-playbook playbooks/check.yml

nginx-reload:
	ansible -m service -a 'name=nginx state=reloaded' web
