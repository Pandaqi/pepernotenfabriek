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
* Het is bijna logisch :p

@TODO







## Een speelbaar spel

@TODO: over wanneer het eigenlijk eindigt/wat je score is, het hele spel rond maken en speelbaar








**THEME/SETTINGS ISSUES LEFT**:

* `use_system_fonts` does not _immediately_ refresh those with "custom font overrrides". Is that bad? Or should I find a different system for that anyway? Is there a way to differentiate 2 labels within the same theme? (One `LabelBody` and one `LabelHeading`? **No, don't think so.**)
* No, I do _not_ actually read settings when bypassing menu at the moment. I should at least make that possible: just call SettingsReader function on all Global.config_shared.settings?
* Also style the TOGGLE (for CheckButton) and SCROLLBAR
* TUTORIAL: Has no text anymore by default (removed that from image), so I must add a label there with translated text myself 
* Switch audio button sound thing back to `_enter_tree` to make sure main menu buttons are included too


SAMEN STOOMBOTEN:

* Do we NEED a tutorial?
* REFACTOR: Have fewer dependencies; if we do need them, INJECT them upon activation/ready
 