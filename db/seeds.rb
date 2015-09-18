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
	Node.create([{rid: 'Trento', name: 'Trento', jira_project_url: 'http://jira.fi-ware.org/browse/TREN', jira_project_id: 'TREN', category_id:1},
	             {rid: 'Berlin2', name: 'Berlin', jira_project_url: 'http://jira.fi-ware.org/browse/BEAR', jira_project_id: 'BEAR'},
	             {rid: 'Lannion2', name: 'Lannion', jira_project_url: 'http://jira.fi-ware.org/browse/LAN', jira_project_id: 'LAN', category_id:3},
	             {rid: 'Prague', name: 'Prague', jira_project_url: 'http://jira.fi-ware.org/browse/PRAG', jira_project_id: 'PRAG', category_id:3},
	             {rid: 'Waterford', name: 'Waterford', jira_project_url: 'http://jira.fi-ware.org/browse/WAT', jira_project_id: 'WAT', category_id:3},
	             {rid: 'Spain2', name: 'Spain', jira_project_url: 'http://jira.fi-ware.org/browse/SEV', jira_project_id: 'SEV'},
		     {rid: 'PiraeusN', name: 'PiraeusN', jira_project_url: 'http://jira.fi-ware.org/browse/NEOR', jira_project_id: 'NEOR'},
	             {rid: 'PiraeusU', name: 'PiraeusU', jira_project_url: 'http://jira.fi-ware.org/browse/UPRC', jira_project_id: 'UPRC'},
	             {rid: 'Karlskrona2', name: 'Karlskrona', jira_project_url: 'http://jira.fi-ware.org/browse/BTH', jira_project_id: 'BTH'},
	             {rid: 'Volos', name: 'Volos', jira_project_url: 'http://jira.fi-ware.org/browse/UTH', jira_project_id: 'UTH'},
	             {rid: 'Gent', name: 'Gent', jira_project_url: 'http://jira.fi-ware.org/browse/IM', jira_project_id: 'IM'},
	             {rid: 'Poznan', name: 'Poznan', jira_project_url: 'http://jira.fi-ware.org/browse/PSNC', jira_project_id: 'PSNC'},
	             {rid: 'Budapest2', name: 'Budapest', jira_project_url: 'http://jira.fi-ware.org/browse/WIG', jira_project_id: 'WIG'},
	             {rid: 'Zurich', name: 'Zurich', jira_project_url: 'http://jira.fi-ware.org/browse/ZHAW', jira_project_id: 'ZHAW'},
	             {rid: 'Stockholm2', name: 'Stockholm', jira_project_url: 'http://jira.fi-ware.org/browse/ASI', jira_project_id: 'ASI', category_id:3},
	             {rid: 'SophiaAntipolis', name: 'SophiaAntipolis', jira_project_url: 'http://jira.fi-ware.org/browse/COM', jira_project_id: 'COM'},
	             {rid: 'SaoPaulo', name: 'SaoPaulo'}])
	
	ActiveRecord::Base.connection.execute('TRUNCATE fi_lab_infographics_node_categories')
# 	Category.delete_all
	Category.create([{name: 'Gold', logo: 'iconMedal1.png', description: 'FIWARE Lab nodes which have been awarded the Gold label under the FIWARE Recognition & Reward Programme fulfill the following requirements: successful participation in FIWARE Lab training, compliance with capacity requirements defined at wiki.fi-xifi.eu/Public:NodeMinimalRequirements, completion of federation into FIWARE Lab, helpdesk for the node, dedicated resources for FIWARE Lab, viable sustainability plan beyond FI-PPP, facilitation of the use of the federation by local users and developers, engagement in the local ecosystem in the creation of FIWARE showcases, offering of additional infrastructure capacities beyond cloud hosting, commitment to long-term operations within FIWARE Lab at least until the end of the FI-PPP'},
	             {name: 'Silver', logo: 'iconMedal2.png', description: 'FIWARE Lab nodes which have been awarded the Silver label under the FIWARE Recognition & Reward Programme fulfill the following requirements: successful participation in FIWARE Lab training, compliance with capacity requirements defined at wiki.fi-xifi.eu/Public:NodeMinimalRequirements, completion of federation into FIWARE Lab, helpdesk for the node, dedicated resources for FIWARE Lab, viable sustainability plan beyond FI-PPP'},
	             {name: 'Bronze', logo: 'iconMedal3.png', description: 'FIWARE Lab nodes which have been awarded the Bronze label under the FIWARE Recognition & Reward Programme fulfill the following requirements: successful participation in FIWARE Lab training, compliance with capacity requirements defined at wiki.fi-xifi.eu/Public:NodeMinimalRequirements, completion of federation into FIWARE Lab'}])
	
	ActiveRecord::Base.connection.execute('TRUNCATE fi_lab_infographics_institutions')
	Institution.create([{name: 'iMinds VZW', logo: 'P24-iMinds.png', link:'http://www.iminds.be/'},
	                    {name: 'Czech Education and Scientific NETwork (CESNET)', logo: 'P28-cesnet.png', link:'http://www.cesnet.cz/?lang=en'},
	                    {name: 'Association Images & Réseaux (ILB)', logo: 'P23-ILB.jpg', link:'http://www.images-et-reseaux.com/en'},
	                    {name: 'Association Plate-Forme Télécom (Com4Innov)', logo: 'P30-Com4Innov.jpg', link:'http://www.com4innov.com/association_presentation.en.htm?PHPSESSID=jrumlj2t7rtqt11ivv0nvhc126'},
	                    {name: 'Deutsche Telekom', logo: 'P21-DT.png', link:'http://www.telekom.com/home'},
	                    {name: 'Fraunhofer FOKUS', logo: 'P11-Fraunhofer-FOKUS.gif', link:'http://www.fokus.fraunhofer.de/en/fokus/index.html'},
	                    {name: 'Neuropublic A.E. PLIROFORIKIS & EPIKOINONION', logo: 'P27-NeuroPublic.png', link:'http://www.neuropublic.gr/'},
	                    {name: 'University of Piraeus Research Center', logo: 'P29-uni-piraeus.gif', link:'http://www.unipi.gr/eng_site/'},
	                    {name: 'University of Thessaly (UTH)', logo: 'P34-UTH.png', link:'http://www.uth.gr/en/index.php'},
	                    {name: 'Wigner Research Centre for Physics', logo: 'P33-Wigner.png', link:'http://wigner.mta.hu/index_e.php'},
	                    {name: 'HEAnet Ltd', logo: 'P20-Heanet.jpg', link:'http://www.heanet.ie/'},
	                    {name: 'Trentino Network SrL', logo: 'P19-TN.png', link:'http://www.trentinonetwork.it/'},
	                    {name: 'Poznan Supercomputing and Networking Center (PSNC)', logo: 'P26-PSNC.jpg', link:'http://www.man.poznan.pl/online/en/'},
	                    {name: 'Entidad Pública Empresarial Red.es/RedIRIS', logo: 'P16-red-es.png', link:'http://www.rediris.es/'},
	                    {name: 'Blekinge Institute of Technology (BTH)', logo: 'P35-BTH.png', link:'http://www.bth.se/eng'},
	                    {name: 'ACREO Swedish ICT AB', logo: 'P31-ACREO.jpg', link:'http://www.acreo.se/'},
	                    {name: 'Zurich University of Applied Sciences (ZHAW)', logo: 'P25-ZHAW.jpg', link:'http://www.zhaw.ch/en/zurich-university-of-applied-sciences.html'},
	                    {name: 'Technical University of Crete', logo: 'Technical-University-of-Crete-TUC.jpg', link:'http://www.tuc.gr/3324.html'},
	                    {name: 'GOWEX Wireless Sl.', logo: 'P32-GOWEX.jpg'},
	                    {name: 'Technische Universität Berlin', logo: 'P22-TUB.png'},
	                    {name: 'Synelixis Lyseis Pliroforikis Automatismou & Tilepikoinonion Monoprosopi EPE', logo: 'P17-synelixis.gif'},
	                    {name: 'Delivery of Advanced network Technology to Europe Limited', logo: 'P18-dante.gif'},
	                    {name: 'i2CAT - RedIRIS subcontractor', logo: 'P16-i2cat.jpg'},
	                    {name: 'Promozione per l\'Innovazione fra Industria e Università Associazione', logo: 'P15-PIIU.jpg'},
	                    {name: 'InterInnov SAS', logo: 'P13-Interinnov.jpg'},
	                    {name: 'Create-Net (Center for REsearch And Telecommunication Experimentation for NETworked Communities)', logo: 'P12-Create-Net.gif'},
	                    {name: 'University of Southampton IT Innovation Centre', logo: 'P10-IT-INN.jpg'},
	                    {name: 'Universidad Politécnica de Madrid', logo: 'P09-UPM.jpg'},
	                    {name: 'Waterford Institute of Technology', logo: 'P08-WIT-2.png'},
	                    {name: 'Engineering - Ingegneria Informatica SpA', logo: 'P07-ENG.png'},
	                    {name: 'Atos SA', logo: 'P06-Atos.jpg'},
	                    {name: 'Thales Communications & Security SAS', logo: 'P05-Thales.gif'},
	                    {name: 'Orange SA', logo: 'P04-FT.jpg'},
	                    {name: 'Telefónica Investigación y Desarrollo S.A', logo: 'P03-Telefonica.jpg'},
	                    {name: 'Eurescom-European Institute for Research and Strategic Studies in Telecommunications GmbH', logo: 'P02-Eurescom.jpg', link:'http://www.eurescom.eu/'},
	                    {name: 'Telecom Italia S.p.A', logo: 'P01-TI.jpg', link:'http://www.telecomitalia.com/tit/en.html'},
	                    {name: 'Martel GmbH', logo: 'Martel_logo_Colour_small.png'},
	                    ])