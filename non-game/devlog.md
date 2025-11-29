# De Pepernotenfabriek (Dagboek)

Welkom bij dit "speldagboek" voor **De Pepernotenfabriek**. Het is een simpel computerspel dat ik maakte voor Sinterklaas, bedoeld om te spelen met meerdere kinderen (of "de hele familie") achter hetzelfde scherm. Het was ook mijn tweede "test" voor mijn idee en systeem voor "One Button Games". Daarom leek het mij interessant om even op te schrijven wat ik heb gedaan en wat ik heb geleerd :)

## Wat is het idee?

Je runt samen een "pepernotenfabriek".

* Over het scherm loopt een simpele loopband.
* Elke speler krijgt één knopje.
* Dat knopje is verbonden met een machine naast die loopband. Als je op de knop drukt, activeer je jouw machine en duwt wat voor je ligt van de loopband.
* Achter de loopband staan simpele bakken waarin de voorwerpen kunnen vallen. Bijvoorbeeld: pepernoten moeten in de mand met het plaatje van een pepernoot.

Het doel is natuurlijk om **de juiste dingen op de juiste plekken te krijgen**. Jij moet _niet_ op de knop drukken als er iets langs komt dat niet in jouw mand moet. Je moet _wel_ op tijd drukken om de juiste dingen in jouw mand te duwen.

Dit voelde als een van de meer simpele en directe ideeën die ik had. Druk op knop = je machine gaat even aan. Een loopband die standaard dingen van links naar rechts over je scherm beweegt is ook makkelijk begrijpen en semi-makkelijk te maken.

Het voelde ook alsof het iets _meer_ moest hebben dan dit. Anders was het te makkelijk. Jij bent de pepernootmachine? Dan druk je op de knop als er een pepernoot langskomt, anders niet. Niet zo veel aan.

Dus ik hield al in mijn achterhoofd dat ik mijn code wat "flexibeler" moest schrijven. Want misschien werkt het spel beter ...

* Met _twee loopbanden_.
* Of met loopbanden die _schuin_ gaan.
* Of als iedereen _twee machines_ bestuurt, etcetera.
* Of als jouw machine ronddraait/beweegt zodat je niet altijd op dezelfde plak staat
* Of als de emmers waarin dingen moeten soms _veranderen_.
* Of misschien staan die emmers _ook_ op een loopband, waardoor het steeds wisselt welke speler in staat is om welke pakjes af te leveren.

## Loopbanden Maken

In 3D is het een ander verhaal, maar in 2D is het redelijk simpel.

* Je rekent de grootte van de loopband uit. (Ik wil dat hij het hele scherm bestrijkt, dus dan gebruik je breedte van het scherm.)
* Je maakt een vierkant gebied dat even groot is en registreert of er dingen in of uit gaan. (Voor Godot is dat een `Area2D` met een `RectangleShape2D`, waarbij je luistert naar de signalen `body_entered` en `body_exited`)
* Zo kan je bijhouden wat er op elk moment op de loopband ligt. Elk frame duw je al die dingen in de richting van de loopband. (Dus als ik hem van links naar rechts laat lopen, dan tel ik `(1,0)` op bij de coördinaten van de pepernoten die erop liggen.)

Als je dit redelijk algemeen opzet, dan zijn loopbanden in alle richtingen mogelijk. Door gewoon die richting te draaien (bijv. boven naar beneden), gaat de hele loopband anders.

Ook werkt dit met meerdere loopbanden. Een pakje kan gewoon op beide loopbanden tegelijk liggen.

Om dingen te laten verschijnen, plaats ik gewoon (eens in de zoveel tijd) iets aan het _begin_ van de loopband. Het zal vanzelf het scherm op komen, de hele weg afleggen, en er aan het einde weer afgaan.

**Werkt dit?** Ja, dit werkte eigenlijk meteen de eerste keer. Dat is best zeldzaam bij spellen maken.

## Machines Maken

Let op dat alle pepernoten (of "dingen die op de loopband kunnen liggen") dus worden geregeld door de "physics". Dat is het ingebouwde systeem in alle game engines dat checkt of dingen tegen elkaar botsen of elkaar raken, en dan de juitse krachten uitrekent.

De algemene regel is dat je physics lekker z'n ding moet laten doen. Niet van bovenaf dingen opleggen, of krachten manipuleren, of wat dan ook. Bijvoorbeeld, dingen kunnen niet teleporteren in het echt, dus als jij ineens iets van plaats verandert dan wordt het hele physics systeem gek en krijg je fouten/crashes! 

Als je physics gebruikt, doe dan _alles_ via dat systeem. Daarom koos ik voor de volgende methode voor de machines.

* De machine "arm" is een vierkant "physics" lichaam.
* Als je op de knop drukt, geef ik die arm een hele hoge kracht naar voren (richting de loopband).
  * Hoe _langer_ je je knop ingedrukt hield, hoe groter die kracht. Je duwt dan dus verder en harder.
* Elk frame vraag ik "goh, hoe ver is die arm inmiddels weggevlogen van de machine?"
  * Hoe verder dit is, hoe harder ik de arm weer terugduw.
  * Totdat hij uiteindelijk weer netjes terug in de machine komt.

Dit zorg ervoor dat ik niet "van buitenaf" dingen moet verplaatsen of stilzetten, maar het helemaal door physics kan laten regelen. Pakjes kunnen nu op allerlei unieke manieren wegstuiteren, afketsen, worden afgeleverd, etcetera. (Unieke manieren, maar ook _realistisch en voorspelbaar voor spelers_.) Dit heeft het extra voordeel dat ik andere grappige soorten machines hiermee kan proberen. (Dat kan niet als ik die arm een vaste animatie maak, of altijd op exact dezelfde manier/exact dezelfde afstand laat bewegen.)

**Werkt dit?** Nee! Nou, ja, het werkt alleen als de machine stilstaat. Zodra hij gaat bewegen of draaien, werkt dit niet meer. Dan kan je bijvoorbeeld de arm wegschieten, en terwijl hij uitgeschoven is draait de machine verder, en dan kan de arm niet meer fatsoenlijk terugkomen, want hij is nog gedraaid zoals toen hij werd weggeschoten! Van die stomme dingen die je meteen ziet als je het hebt gebouwd, maar die je nooit bedenkt als je het originele idee opschrijft.

Ik moet toegeven dat ik een uur heb lopen puzzelen met allerlei mogelijke oplossingen hiervoor. Physics blijft soms een beetje een duistere magie waarbij je net even dat trucje moet vinden om de game engine te laten doen wat je wilt. Moest ik toch niet via physics werken? Moest ik de arm daadwerkelijk langer/korter maken ipv uitschuiven? Moest ik iets heel anders proberen?

Uiteindelijk was het trucje om **rails te bouwen rondom de uitschuifarm**. 

* De arm zit vast aan de machine met een speciale "joint". (Een `GrooveJoint` in dit geval; vrijwel alle game engines hebben dit soort dingen ingebouwd).
* Deze joint zegt "deze twee dingen mogen alleen in één richting bewegen ten opzichte van elkaar". (In dit geval natuurlijk de richting waarin de machine kijkt/de arm uitschuift.)
* In alle andere richtingen blijven ze dus aan elkaar vastzitten! Dus als de machine draait, dan draait de arm netjes mee, en tegelijkertijd kan hij nog steeds uitgeschoven.
* MAAR! De arm draait dan ook om z'n eigen as, in plaats van netjes vooruit te blijven wijzen. Want ja, dat is realistisch. In het echt draaien dingen vrijuit ... tenzij je ze tegenhoudt.
  * Dus elke machine heeft stiekem twee rechthoeken langs de uitschuifarm (links en rechts, heel dicht erop) die hem "in het gareel houden". 
  * Die rechthoeken zijn net zo lang als de maximale lengte waarop de arm kan uitschuiven. Dus hoe ver hij ook uitschuift, hij blijft gedraaid zoals je verwacht.
  * (Alle andere dingen in het spel botsen _niet_ met deze onzichtbare "veiligheidsrails".)

@TODO: PLAATJE HIERVAN (OPMERKING: De cirkel is dan de machine, de middelste van de drie rechthoeken is degene die daadwerkelijk los zit en kan bewegen.)

Op deze manier kan ik de machines laten draaien, bewegen, en uitschuiven volledig via de "physics". Dit betekent dat alle botsingen enzo altijd kloppen, welke rare pakjes ik ook op de loopband gooi en wanneer je ook de knop gebruikt.

Dit proces zette mij echter wel aan het denken dat er misschien leukere/andere manieren zijn om dit spel te besturen.

* De machines zouden pepernoten kunnen _schieten_. Da's veel makkelijker: je vuurt gewoon een klein bolletje af en dat is het.
* De machines zouden gewoon een vaste arm kunnen hebben (in plaats van uitschuiven), en jouw knop laat de machine slechts _draaien_.
* Etcetera

Allemaal opties om later te bekijken. Voor nu werkt mijn originele idee met de uitschuifmachines.

## Pepernoten Afleveren

Dit is vrij simpel vergeleken met de rest.

* Ik maak weer een `Area`, en deze keer op `body_entered` checkt hij of het een pakje is. Zo ja, dan is het nu afgeleverd.
* Ik maak een plaatje van "hier afleveren" dat even groot is als die Area.

Het interessante deel hier is denk ik dat ik "object pooling" gebruik. 

* Ik zou de hele tijd pakjes kunnen _maken_, en dan weer kunnen _vernietigen_ als ze in de container belanden.
* Maar maken en vernietigen zijn vaak de zwaarste dingen voor een game engine, en ze kunnen dus ook de physics in de war brengen.
* In plaats daarvan maak ik (helemaal aan het begin) een "pool" van 30 pakjes. En die worden gewoon steeds hergebruikt.
  * We hebben een pakje nodig? Haal de eerste uit de pool en gooi hem op de loopband.
  * Een pakje is afgeleverd? Maak hem onzichtbaar en gooi hem terug in de pool.

Dit is lekker efficiënt en zet tegelijkertijd een mooie limiet op het maximale aantal pakjes. 

{{% remark %}}
In oudere spellen van mij vergat ik dat wel eens, en vervolgens deden mijn spelers hun uiterste best om 100+ dingen op het scherm te laten komen en de computer te laten crashen. Limieten zijn goed! Restricties zorgen voor creativiteit!
{{% /remark %}}

## De Fabriek Maken

Ondertussen heb ik een nachtje geslapen. De volgende ochtend wil ik beginnen met de fabriek maken, oftewel, hij "genereert" willekeurig wat loopbanden en machines waarmee je speelt.

En dan zie ik een (achteraf overduidelijk) probleem.

* One Button Games kunnen meestal van 2 tot 6 of 8 spelers.
* Tegelijkertijd moet de fabriek zodanig zijn gebouwd dat je altijd een kans hebt om een pakje in een emmer te krijgen. Als het pakje bijvoorbeeld nooit langs jou komt, of de emmer ervoor staat niet aan de andere kant, dan... kan je hem letterlijk niet afleveren!
* Dus hoe garanderen we dat?
* En hoe werkt dat als het aantal spelers---en dus het aantal machines---niet altijd hetzelfde is?

Meestal bedenkt je hoofd dan een aantal oplossingen die vast heel netjes zouden werken, maar ook véél te complex of tijdrovend zijn. Bijvoorbeeld,

* Ik zou kunnen zeggen "één loopband per 2 spelers". Dus zodra een 3e speler inlogt, verschijnt plots een _tweede loopband_ in de fabriek, waar zij dan verantwoordelijk voor zijn.
* Ik zou de loopband kunnen veranderen naar een _pad_ (ipv gewoon een rechte lijn). Zo kan je een cirkel maken, wat garandeert dat iets natuurlijk overal langskomt. Nieuwe spelers krijgen gewoon een nieuwe machine ergens op een lege plek langs dit pad/deze cirkel.
* En meer van dit soort ingenieuze oplossingen.

Maar ik wil dit graag klein en simpel houden. Dus ik bedacht het volgende voor de fabrieksgeneratie,

* Houdt stiekem een "grid" bij. (Dus je deelt het scherm op in nette vakjes.) Dit is puur om op te slaan waar al dingen staan, zodat je weet welke vakjes nog leeg zijn.
* Plaats eerst ~3 loopbanden. (En alle gridvakjes die ze gebruiken, die markeer je dus als "vol"!)
* Plaats vervolgens 6 machines op vakjes langs de loopbanden. (Ook die vakjes zijn nu natuurlijk "vol".)
* En nu komt de truc,
  * Ga langs alle overgebleven vakjes.
  * Trek een lijn van dat vakje naar elke machine.
  * Als er tenminste één zo'n lijn is die _kruist met een loopband_, dan weet je dus het volgende: er staat een machine aan de _ene kant_ van de loopband, en deze emmer zou aan de _andere kant_ komen. Dus hij is bereikbaar. Hier kan je een emmer plaatsen!
  * Ik geef voorkeur aan vakjes die zoveel mogelijk machines kunnen bereiken + zo dicht bij de loopband mogelijk staan. Dáár plaats ik emmers.

En wat als er minder dan die 6 spelers zijn? Dan worden de machines gewoon _verdeeld_ over de spelers. **Sommige spelers besturen dus twee machines tegelijk.**

Het is niet perfect. Ook nu kan je toevallig een fabriek krijgen die net wat minder speelbaar is, bijvoorbeeld doordat machines net in elkaars lijn zitten. Het is wel de meest simpele/efficiënte manier om al deze problemen in één klap op te lossen.

De _breedte_ van de loopbanden is identiek aan die van vakjes in het grid. Dat leek me een goed ijkpunt. De machines en emmers zijn net ietsje kleiner zodat ze fijn in één vakje passen met wat witruimte eromheen.

O ja, iets wat dit algoritme duizend keer beter maakte was om een maximale afstand te hebben tussen machines. Dus het telt alleen "deze emmer kan worden bereikt door machine X" als hij behoorlijk dichtbij staat (binnen 4 gridvakjes volgens mij). Die ene regel code maakt de hele fabriek een stuk mooier en speelbaarder dan eerst.

## Lastige Keuzes Maken

Zoals ik aan het begin al vermoedde: met één loopband, en de machines netjes ernaast, is het spel gewoon niet echt een spel. Je drukt op de knop als precies jouw pakje langskomt, en dat is het.

Meerdere loopbanden maakt het al beter, maar dan moet je de machines dus draaien (of een veel slimmer algoritme schrijven voor genereren van de fabriek).

En als machines moeten draaien, en eventueel een redelijke afstand moeten overbruggen ... dan werkt zo'n uitschuifarm niet meer. Dan moet je dingen kunnen afvuren / over grotere afstand werken.

En als je dus zoveel vrijheid hebt, dan moet ik eigenlijk ook toestaan dat pakjes niet worden opgepikt door "foute" containers (maar eroverheen vliegen). Want nu krijg je soms fabrieken waarbij emmers achter elkaar staan en je moet toch echt dat pakje eerst langs die andere emmer krijgen.

Dit soort dingen worden altijd vrij snel duidelijk nadat je iets hebt gemaakt. Meestal is dat eerste idee ook helemaal niet goed, en dan voelt het een beetje alsof je tijd hebt verspild ("ugh waarom werken mijn ideeën nooit in één keer"). Maar dat is dus niet zo, want dit was nodig om te zien hoe het wel moest.

Uiteindelijk moet ik mezelf steeds herinneren dat het gaat om _een leuk spel_. Houd dingen simpel. Kies gewoon iets wat grappig en speels is, dat is belangrijker dan dat iets helemaal "eerlijk" of "speelbaar" is.

Dus het werd...

* Pepernoten afvuren vanuit je machine. 
* Die pepernoten herladen alleen als ze uit het scherm vliegen. Dus je kan ook gewoon verliezen door te slecht te schieten en je hele fabriek vol stilstaande pepernoten te hebben.
* Die pepernoten knallen tegen pakjes, en zo moeten ze in de emmer.
* Het is bijna logisch, hoe je zo'n fabriek runt :p

Dat is het algemene idee. Er waren ook een hoop kleine dingetjes die het spel fijner maakten.

* Ik veranderde de code voor loopbanden om ze "strenger" te maken. Een pakje behoort maar tot één loopband (dat is gewoon leuker spelen dan als er twee of drie banden tegelijk aan kunnen sjorren). Ook trekt de loopband harder om het pakje "in het gareel" te krijgen, zodat ze duidelijker meegaan met de band.
* Er zit een limiet op de hoeveelheid pakjes, en hoe snel ze verschijnen, op basis van het _aantal actieve spelers_. Met meer spelers kan je veel meer pakjes aan; als je met maar 2 spelers bent is datzelfde aantal natuurlijk al snel overweldigend.
* Ik maakte de pepernoten die je schiet een stuk groter dan eerst. (Eerst waren het meer "kogels", meer "realistische grootte".) Dat maakt ze gewoon beter zichtbaar en maakt het makkelijker om dingen te raken.

Het allerlastigste was het spel speelbaar maken voor zowel 2 spelers als (maximaal) 8 spelers. Ik was een paar uur bezig met van alles testen, zoals

* Iedereen bestuurt één machine, maar je kan switchen door heel snel/kort je knop in te drukken. (Met 2 spelers moet je dan alsnog de hele tijd tussen 4 machines heen en weer, en dat was gewoon te lastig.)
* De machines worden volledig opgedeeld. (Met 2/3 spelers schiet elke speler dan de hele tijd 3/4 pepernoten tegelijk, en dat is een rotzooi.)
* Ik schakel gewoon alle overbodige machines uit. (Maakt het spel weer overzichtelijk en simpel, maar zorgt dus ook dat je allerlei pakjes überhaupt nooit had kunnen raken ... omdat die machines dus weg zijn.)
* Maar als ik het aantal machines omlaag doe, of de kaart versimpel, is het spel weer saai/meh met 4(+) spelers.

De wanhoop nabij zag ik toen eindelijk het licht :p

* Ik stel een "maximum" aantal machines per speler in. Dus zelfs met weinig spelers kan je er maar 2 tegelijk hebben.
* Maar je kan nog steeds _switchen_ van machine---maar dan _allebei tegelijk_.
* Zo kan één speler effectief 4 machines hebben (of je bestuurt A+B, of je bestuurt C+D). Dat is overzichtelijk, dat is te doen, dat is "speelbaar".
* Tegelijkertijd kan je zo dus zelfs met 2 spelers de volledige fabriek beslaan.

## Een speelbaar spel

Het grote probleem met dit project was dat ik eigenlijk nooit had vastgelegd wat nou je _doel_ was. Het is een coöperatief spel. Het moet ook te spelen zijn met jonge kinderen, op bijv Sinterklaasavond. Dus iets heel competitiefs zag ik niet zitten, en iets heel strengs ook niet (zoals verliezen/doodgaan als je 10 pakjes hebt gemist bijvoorbeeld),

Het spel moet luchtig en grappig blijven. Het is expres lastig om de fabriek te besturen, dus foute pakjes moeten geen (grote) straf hebben. Het moet juist grappig zijn---het moet goed voelen als je wél een paar dingen op rij goed aflevert. Het moet _simpel_ zijn.

Zo kwam ik uit bij het volgende doel.

* Er is wel een score, maar die is niet cruciaal (zodat kinderen die getallen nog niet kennen ook begrijpen of ze goed bezig zijn)
* Je wilt gewoon "genoeg dingen klaarmaken". Dus alles wat je aflevert brengt je verder richting "100%". 
  * Als in: het spel eindigt als je daar komt (je hebt X dingen goed afgeleverd). Je _score_, die het eindscherm prominent toont, staat los daarvan.
* Maar je wordt wel beloond voor minder dingen verspillen, natuurlijk. Namelijk:
  * COMBO (1): Het spel houdt bij wat jouw pepernoten raken. Zolang jij dingen raakt die uiteindelijk worden afgeleverd, gaat jouw "streak" door en scoor je meer punten voor alles wat jij aflevert.
  * COMBO (2): Het spel houdt ook in het geheel bij of iets niet op tijd wordt afgeleverd. Als dat gebeurt, gaat de "streak" van je hele groep weer naar nul.
  * LANGER HOUDBAAR: Andersom, als het niet zo lekker gaat, blijven dingen langer op het veld liggen voordat ze verdwijnen. Zo raak je nooit helemaal in een negatieve spiraal, want dat is niet leuk.

Nou goed, zoals je ziet duurt dit hele project al een stuk langer dan ik in eerste instantie had gepland. Maar ik leer weer een hele hoop nieuwe dingen, want ik heb bijvoorbeeld (op een of andere manier) nog nooit streaks/combos geprogrammeerd in een eerder spel. En uiteindelijk is iteratie toch het toverwoord voor spellen maken, nog meer dan bij alle andere creatieve uitingen.

En dan ... is het eindelijk af.

Met elk spelersaantal is de fabriek speelbaar. (Na een hoop finetunen van getalletjes, zoals altijd, lijkt de moeilijkheidsgraad en snelheid van dingen goed.) Het is overzichtelijk. Er komt wat geluk/pech bij kijken, maar je kunt ook echt beter worden in strategie en mikken van je pepernoten. Het is niet te erg/frustrerend als je een aantal dingen laat gaan of mist, maar je wilt wel echt foutloos blijven om je streak in leven te houden en zo veel meer punten te scoren.

Ik voegde nog wat laatste geluidseffecten en animaties toe. Ik voegde nog wat laatste geniepige hulpmiddelen toe om spelers meer plezier te laten hebben, zoals vrijwel elk spel doet.

De belangrijkste? **Je wordt enorm geholpen bij het richten van je machine/pepernoten.** Als je "dichtbij genoeg" bent, verandert hij je richting een beetje om je te helpen ("aim assistance"). De truc hier is natuurlijk dat het onzichtbaar is, dus als je echt verkeerd mikt gaat hij gewoon verkeerd. Maar als je in de buurt komt dan zal je sowieso iets raken. Dat werkt volgens een vrij simpel mechanisme.

* Reken de hoek uit tussen je machine en alle pakjes in het veld.
* Reken de hoek uit waarop je nu richt ( = de hoek waarin je normaal gesproken zou schieten, zonder aim assistance)
* Vind het pakje met de hoek die het _dichtste bij_ jouw richthoek ligt.
  * Als je héél dichtbij bent, doe dan niks---je richt al goed.
  * Als je er iets verder van af zit, duw je richting dan dichterbij die "perfecte richting" (maar niet helemaal---controle moet bij de speler blijven, en een beetje willekeurigheid maakt dit mooier.) Dus als je eronder zit, duw ik je hoek naar boven. Als je erboven zit, duw ik je hoek naar onder. 
  * Maar als je er nóg verder van af zit, doe dan weer helemaal niks---je schiet zó mis dat het systeem je lekker laat missen.

{{% remark %}}
In eerste instantie deed ik dit met een "homing algoritme" op de pepernoten zelf. Dus terwijl ze vlogen, keken ze om zich heen en werden als magneten aangetrokken tot het dichtstbijzijnde pakje. Dit werkt doorgaans erg goed ... maar niet in een spel met zo'n klein veld en zoveel andere dingen die je zou kunnen raken. Het algoritme wordt afgeleid en doet niet vaak genoeg wat je wilt, en als je de magneet dan superkrachtig maakt is het té overduidelijk en ziet het er stom uit.

Dus toen switchte ik naar de _machine_. Die corrigeert de richting _waarop je schiet_ (helemaal aan het begin), daarna vliegt de pepernoot gewoon in een rechte lijn. Dat ziet er in dit geval veel natuurlijker uit, en het speelt echt veel fijner, want je mist dus niet drie keer op rij op een haar na hetzelfde pakje :p
{{% /remark %}}

## Conclusie

Uiteindelijk heb ik ~3 dagen over dit spel gedaan. Het werd wat groter en ingewikkelder dan ik hoopte vanwege de fouten en praktische missers in mijn eerste idee. Tegelijkertijd ben ik trots op het vrij sterke algoritme voor het genereren van willekeurige fabrieken die tot nog toe allemaal speelbaar zijn geweest, en het vrij vloeiend ondersteunen van lage en hoge spelersaantallen.

Het spel is niet groots, maar het is wel grappig om even met een groep te doen tijdens Sinterklaas. En daar ging het toch vooral om.

Bij het dagboek van _Samen Stoomboten_ legde ik al meer uit over het "systeem" achter de One Button Games. Dit was het tweede spel dat ik er ooit mee maakte, dus het systeem is nog verre van af. Maar door het te _gebruiken_ voor iets, vind ik steeds nieuwe dingen om toe te voegen en te verbeteren. Zo vond ik dankzij dit spel een cruciale (domme) fout in een deel van het systeem, die zorgde dat iets 95% van de tijd werkte ... en 5% van de tijd het hele spel liet crashen.

Met elke One Button Game wordt dat systeem weer wat schoner en bruikbaarder voor _volgende_ spellen. Voor nu kan je lekker pepernoten schieten in deze pepernotenfabriek.

Tot de volgende keer,

Tiamo







@TODO VOOR SPEL:

* UITLEGPLAATJES
* Settings + Localization (specifiek voor spel)


REMEMBER: When doing object pooling, have a delay before giving it back, to make sure it has probably turned off physics and finished tweens and stuff before it's being reused. Current solution = add back to back, pop from front, which makes it very unlikely it's reused.


**THEME/SETTINGS ISSUES LEFT**:

* SETTINGS IN DEFAULTS
  * TUTORIAL
  * TUTORIAL SCALE/FONT SIZE 
  * CLICK_INSTRUCTION_TO_LOGIN
* `use_system_fonts` does not _immediately_ refresh those with "custom font overrrides". Is that bad? Or should I find a different system for that anyway? Is there a way to differentiate 2 labels within the same theme? (One `LabelBody` and one `LabelHeading`? **No, don't think so.**)

* **The button instructions can be much smaller and more concise.** No need for the whole panel around it. That would also fit more instructions. Just a Nintendo-style "button/icon + small outlined text" would be fine, no?
* The buttons for the all-important pause menu (Escape/Gamepad??/Touch??) should be much better explained. => Show this on the PAUSE MENU, as that's where you start each game anyway + reminds you how to get away.
  * Some small fixed buttons for ESCAPE / GAMEPAD START / TOUCH LOGOUT below it should do?

* Create an actual `one-button-games` Git project? At least for backup, but also to collect my notes and this to-do and stuff. (Can merge that with the ideas and stuff inside the existing folder. The other games should be ignored for being Git-submodules.)
* Add a little text with the game name, that I created it, the version, etc on the start screen. Makes it look more professional.

**OTHER**:
* Add more tweens to `TweenManager` and make that system more robust
* Move some of those modules (map bounds, pooling, etc) into OBG for standardized reuse?
* I COULD maybe style the TOGGLE (for CheckButton) in same style as other buttons, but not necessary right now.



SAMEN STOOMBOTEN:

* Do we NEED a tutorial?
* REFACTOR: Have fewer dependencies; if we do need them, INJECT them upon activation/ready
 