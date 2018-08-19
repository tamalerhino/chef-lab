# chef-lab
A lab to play with chef

## Chef Lab setup.

The lab sets up a basic Chef Server, Chef Automate, Two web servers, and a load balancer. 
They are highly unsecured, do not use for production systems.
This lab was meant for teaching purpouses only.

## Prerequisites
 
* Git
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](https://www.vagrantup.com/)
* [Chef Development Kit - ChefDK](https://downloads.chef.io/chef-dk/)


## Steps being done by `bootstrap-chef-server.sh` script
* Downloads and unpackages the chef-server deb file.
* Create a first user to be able to log in into Chef Server
* Create an Org and associate the user to this Org.
* Install Chef Manage, this is the Web interface for Chef Server.
* Install Chef Reporting.

The lines modifying the hosts file allow chef-server box to talk to all other nodes without knowing the IP's.


## Step One - Setting up Chef Server

Git clone this repo

```
git clone https://github.com/chito4/chef-lab
cd chef-lab
```
Then run the Vagrantfile, if this is the first time you have ran this, it will take a long time 10-25 min depending on your hardware
```
vagrant up chef_server
```
Once that's done you can open up your browser and go to: `https://chef-server/`

You will get a certificate exception, that's OK you can skip it and continue.

Login with `testlabdev` and password `password`

## Step 2 - Configure Chef Automate- (OPTIONAL)
You dont necesearlly need this but if you want to learn how to use automate do this as well.

Make sure that __ChefDK__ is installed and part of you PATH:

```
vagrant up chef_automate
```
You will have to login to accept the T&C

```
chef-automate deploy
```

## Step 3  - Downloading the right files and creating a cookbook to test
Your next step is to download Chef Starter Package unto your WORKSTATION from you current Chef Server installation:

* Go to [https://chef-server/organizations](https://chef-server/organizations)
* Click __testcheflab__
* On the left menu search for __Starter Kit__ and click on it.
* Click on "Download Starter Kit"
* Click on "Proceed"

This will download a `.zip` file, the objective is to have the `chef-starter-repo` next to `chef-lab` directory.

Unzip the file and you should have something like this:

```
[dev@workstation]$ ls
chef-repo  chef-lab
```

__Chef repo__ directory is where most of the work would happen. 
Here you will create cookbook, recipes, assign roles to nodes and make tests for you recipes.

The first step is to make contact with Chef server.

```
cd chef-repo
 knife ssl fetch
 knife ssl check
 chef verify
//This last command will take a while
```

Now you're ready to start creating cookbooks.

### Uploading your first recipe to Chef Server.

You will want to upload at least one test cookbook to make sure its all up and running, a `hello world` will do
```
cd chef-repo <--- Make sure you're at the root of the project
knife cookbook upload test-cookbook
```

Open up your browser and go to [https://chef-server/organizations/testcheflab/cookbooks](https://chef-server/organizations/testcheflab/cookbooks)

You will see your new `test-cookbook` cookbook now hosted on your local chef server.

## Step 4 - Bootstrapping nodes

Go back to the `chef-lab` directory and bring up the missing boxes.

```
cd ../chef-lab
vagrant up lb web2 web3
```

Right now, our web-servers don't know how to communicate to our installation of Chef server. `knife` provides an easy way to 
do this. Usually you run this once.

```
cd ../chef-repo
knife bootstrap web3 -x vagrant -P vagrant --sudo --verbose --node-name web3-node
knife bootstrap web2 -x vagrant -P vagrant --sudo --verbose --node-name web2-node
knife bootstrap lb -x vagrant -P vagrant --sudo --verbose --node-name lb-node
```

You can go to [https://chef-server/organizations/testcheflab/nodes](https://chef-server/organizations/testcheflab/nodes) and you will see your new nodes.


### Step 5 - Adding roles

A role is a way to define certain patterns and processes that exist across nodes in an organization as belonging to a single job function. 
Each role consists of zero (or more) attributes and a run-list. Each node can have zero (or more) roles assigned to it. 
When a role is run against a node, the configuration details of that node are compared against the attributes of the role, and then the contents 
of that role’s run-list are applied to the node’s configuration details. When a chef-client runs, it merges its own attributes and run-lists with 
those contained within each assigned role.

Create a new file under roles directory:

```
{
  "name": "webapp-role",
  "description": "Role to configure all web nodes",
  "chef_type": "role",
  "run_list": [
    "recipe[test-cookbook::default]"
  ]
}
```

Add the roles to your nodes:
```
knife node run_list add web2-node 'role[webapp-role]'
knife node run_list add web3-node 'role[webapp-role]'
```

Now we have to run chef-client on each of the boxes.

```

/chef-lab
vagrant ssh web2

```

Inside do this:
```
[vagrant@web2 ~]$ sudo chef-client
//after it finishes
[vagrant@web2 ~]$ exit
```

Now do the same for web3:

```
[vagrant@web3 ~]$ sudo chef-client
[vagrant@web3 ~]$ exit
```
And fimally for the lb

```
[vagrant@lb ~]$ sudo chef-client
[vagrant@lb ~]$ exit
```
## TODO:
* Figure out how to automatically accept license for chef automate
* other stuff that im forgetting to do.
