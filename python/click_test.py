import click
import os

@click.command()
@click.option('--count', default=1, help='Number of greetings.')
@click.option('--name', prompt='Your name',help='The person to greet.')
@click.option('--number', default="8791134412", help='Required Phone Number')
@click.option('--u', default="http://ncprstatus.in/api/v1/status?numbers=", help='Required URL')
@click.option('--url', default="http://ncprstatus.in/api/v1/status?numbers=", help='Required URL')

#Test Case3 related options
@click.option('--url', default="http://ncprstatus.in/api/v1/status?numbers=", help='Required URL')

def hello(count, name, number, url):
    """Simple program that greets NAME for a total of COUNT times."""
    print 'Count is ', count
    print 'Number is ', number
    print 'URL is ', url
    click.echo(os.system('curl '+url+number))
#    for x in range(count):
#        click.echo('Hello %s!' % name)


if __name__ == '__main__':
    hello()
