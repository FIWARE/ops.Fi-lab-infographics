# ruby encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
	ActiveRecord::Base.connection.execute('TRUNCATE fi_lab_infographics_nodes')
# 	Node.delete_all
	Node.create([{rid: 'Trento', name: 'Trento', jira_project_url: 'http://jira.fi-ware.org/browse/TREN', jira_project_id: 'TREN'},
	             {rid: 'Lannion2', name: 'Lannion', jira_project_url: 'http://jira.fi-ware.org/browse/LAN', jira_project_id: 'LAN'},
	             {rid: 'Prague', name: 'Prague', jira_project_url: 'http://jira.fi-ware.org/browse/PRAG', jira_project_id: 'PRAG'},
	             {rid: 'Spain2', name: 'Spain', jira_project_url: 'http://jira.fi-ware.org/browse/SEV', jira_project_id: 'SEV'},
	             {rid: 'PiraeusU', name: 'PiraeusU', jira_project_url: 'http://jira.fi-ware.org/browse/UPRC', jira_project_id: 'UPRC'},
	             {rid: 'Volos', name: 'Volos', jira_project_url: 'http://jira.fi-ware.org/browse/UTH', jira_project_id: 'UTH'},
	             {rid: 'Poznan', name: 'Poznan', jira_project_url: 'http://jira.fi-ware.org/browse/PSNC', jira_project_id: 'PSNC'},
	             {rid: 'Budapest2', name: 'Budapest', jira_project_url: 'http://jira.fi-ware.org/browse/WIG', jira_project_id: 'WIG'},
	             {rid: 'Zurich2', name: 'Zurich', jira_project_url: 'http://jira.fi-ware.org/browse/ZHAW', jira_project_id: 'ZHAW'},
	             {rid: 'SophiaAntipolis2', name: 'SophiaAntipolis', jira_project_url: 'http://jira.fi-ware.org/browse/COM', jira_project_id: 'COM'},
	             {rid: 'SaoPaulo', name: 'SaoPaulo'},
	             {rid: 'Crete', name: 'Crete'},
	             {rid: 'SpainTenerife', name: 'SpainTenerife'},
	             {rid: 'Vicenza', name: 'Vicenza'},
	             {rid: 'Brittany', name: 'Brittany'},
	             {rid: 'ZurichS', name: 'ZurichS'},
	             {rid: 'Trento2', name: 'Trento'},
	             {rid: 'Hannover', name: 'Hannover'},
	             {rid: 'Genoa', name: 'Genoa'}])
	
	ActiveRecord::Base.connection.execute('TRUNCATE fi_lab_infographics_node_categories')
# 	Category.delete_all
	Category.create([{name: 'Gold', logo: 'iconMedal1.png', description: 'FIWARE Lab nodes which have been awarded the Gold label under the FIWARE Recognition & Reward Programme fulfill the following requirements: successful participation in FIWARE Lab training, compliance with capacity requirements defined at wiki.fi-xifi.eu/Public:NodeMinimalRequirements, completion of federation into FIWARE Lab, helpdesk for the node, dedicated resources for FIWARE Lab, viable sustainability plan beyond FI-PPP, facilitation of the use of the federation by local users and developers, engagement in the local ecosystem in the creation of FIWARE showcases, offering of additional infrastructure capacities beyond cloud hosting, commitment to long-term operations within FIWARE Lab at least until the end of the FI-PPP'},
	             {name: 'Silver', logo: 'iconMedal2.png', description: 'FIWARE Lab nodes which have been awarded the Silver label under the FIWARE Recognition & Reward Programme fulfill the following requirements: successful participation in FIWARE Lab training, compliance with capacity requirements defined at wiki.fi-xifi.eu/Public:NodeMinimalRequirements, completion of federation into FIWARE Lab, helpdesk for the node, dedicated resources for FIWARE Lab, viable sustainability plan beyond FI-PPP'},
	             {name: 'Bronze', logo: 'iconMedal3.png', description: 'FIWARE Lab nodes which have been awarded the Bronze label under the FIWARE Recognition & Reward Programme fulfill the following requirements: successful participation in FIWARE Lab training, compliance with capacity requirements defined at wiki.fi-xifi.eu/Public:NodeMinimalRequirements, completion of federation into FIWARE Lab'}])
	
	ActiveRecord::Base.connection.execute('TRUNCATE fi_lab_infographics_institutions')
	Institution.create([{name: 'Czech Education and Scientific NETwork (CESNET)', logo: 'P28-cesnet.png', link:'http://www.cesnet.cz/?lang=en'},
	                    {name: 'Association Images & Réseaux (ILB)', logo: 'P23-ILB.jpg', link:'http://www.images-et-reseaux.com/en'},
	                    {name: 'Association Plate-Forme Télécom (Com4Innov)', logo: 'P30-Com4Innov.jpg', link:'http://www.com4innov.com/association_presentation.en.htm?PHPSESSID=jrumlj2t7rtqt11ivv0nvhc126'},
	                    {name: 'University of Piraeus Research Center', logo: 'P29-uni-piraeus.gif', link:'http://www.unipi.gr/eng_site/'},
	                    {name: 'University of Thessaly (UTH)', logo: 'P34-UTH.png', link:'http://www.uth.gr/en/index.php'},
	                    {name: 'Wigner Research Centre for Physics', logo: 'P33-Wigner.png', link:'http://wigner.mta.hu/index_e.php'},
	                    {name: 'Trentino Network SrL', logo: 'P19-TN.png', link:'http://www.trentinonetwork.it/'},
	                    {name: 'Poznan Supercomputing and Networking Center (PSNC)', logo: 'P26-PSNC.jpg', link:'http://www.man.poznan.pl/online/en/'},
	                    {name: 'Entidad Pública Empresarial Red.es/RedIRIS', logo: 'P16-red-es.png', link:'http://www.rediris.es/'},
	                    {name: 'Zurich University of Applied Sciences (ZHAW)', logo: 'P25-ZHAW.jpg', link:'http://www.zhaw.ch/en/zurich-university-of-applied-sciences.html'},
	                    {name: 'Technical University of Crete', logo: 'Technical-University-of-Crete-TUC.jpg', link:'http://www.tuc.gr/3324.html'},
	                    {name: 'University of São Paulo', logo: 'Logo_USP.png', link:'http://www5.usp.br/'},
	                    {name: 'Engineering', logo: 'logo_eng.jpg', link:'http://www.eng.it/'},
	                    {name: 'Atos', logo: 'Atos.jpg', link:'http://www.atos.net/'},
	                    {name: 'SWITCH', logo: 'switch-logo.gif', link:'https://www.switch.ch/'},
	                    {name: 'Netzlink', logo: 'logo-netzlink.png', link:'https://www.netzlink.com/'},
	                    {name: 'Consorzio Nazionale Interuniversitario per le Telecomunicazioni (CNIT)', logo: 'Logo-CNIT.png', link:'http://www.cnit.it/node/100'},
	                    {name: 'Tasgroup', logo: 'tasgroup.png', link:'https://www.tasfrance.com/'}
	                    ])
	
	ActiveRecord::Base.connection.execute('TRUNCATE fi_lab_infographics_nodes_institutions')
	ActiveRecord::Base.connection.execute('INSERT INTO fi_lab_infographics_nodes_institutions VALUES(3,1),
					      (2,2),
					      (10,3),
					      (10,18),
					      (5,4),
					      (6,5),
					      (8,6),
					      (1,7),
					      (7,8),
					      (4,9),
					      (9,10),
					      (12,11),
					      (11,12),
					      (17,7),
					      (14,13),
					      (13,14),
					      (16,15),
					      (18,16),
					      (19,17)')
