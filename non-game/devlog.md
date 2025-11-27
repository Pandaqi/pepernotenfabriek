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

@TODO: Over emmers die dat checken, de object pooling voor het geheel

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
 