# Cloud Bridge Engine - Architektura i Koncepcja

## 1. Wizja Projektu
Cloud Bridge Engine to samodzielna, skalowalna platforma integracyjna (tzw. "Zapier Killer") skierowana do sektora B2B. Umożliwia automatyzację procesów biznesowych bez generowania kosztów stałych dzięki architekturze FinOps ($0 utrzymania).

## 2. Architektura Infrastruktury (ZROBIONE)
Cała infrastruktura jest definiowana jako kod (IaC) przy użyciu narzędzia **Terraform** i hostowana w chmurze **Oracle Cloud Infrastructure (OCI)** w ramach planu Always Free.

* **Sieć (VCN):** Izolowana sieć wirtualna z jednym publicznym podsiecią.
* **Bezpieczeństwo:** Security List odblokowuje wyłącznie niezbędny ruch (Porty: 22 dla SSH, 80 dla HTTP, 443 dla HTTPS).
* **Serwer (Compute):** * Model: `VM.Standard.E2.1.Micro` (Architektura x86_64 / AMD)
    * Zasoby: 1 OCPU, 1 GB RAM, 50 GB Dysk.
    * Optymalizacja: Dodano **4 GB pamięci Swap**, aby zabezpieczyć aplikacje przed brakiem RAM-u.
* **System Operacyjny:** Oracle Linux 8 (natywny obraz chmury zapewniający 100% stabilności uprawnień).

## 3. Stos Technologiczny i Usługi (W TRAKCIE)
Wszystkie aplikacje będą działać w izolowanych kontenerach za pomocą **Dockera** i **Docker Compose**.

1.  **n8n (Workflow Automation Engine):** Serce systemu. Wizualny edytor do budowania automatyzacji. Będzie nasłuchiwał zdarzeń i wykonywał API calls.
2.  **Supabase (Baza Danych ODS):** Operacyjny Magazyn Danych. Stanowi darmową, hostowaną bazę PostgreSQL z gotowym interfejsem REST API. Będziemy tam zapisywać wyciągnięte dane przed ich wysłaniem dalej (Gwarancja spójności danych).
3.  **Slack (Komunikator):** Odbiornik powiadomień. Standard B2B do komunikacji zespołowej.

## 4. Logika Biznesowa - Główne Przepływy (PLANOWANE)

### Flow 1: Pobieranie Kursów Walut (Core Feature)
1.  **Wyzwalacz (Trigger):** Codziennie rano (Cron).
2.  **Akcja 1:** Pobranie danych przez HTTP Request do otwartego API NBP.
3.  **Akcja 2:** HTTP Request (POST) do REST API Supabase, aby zapisać dzisiejszy kurs w bazie.
4.  **Akcja 3:** Oczekiwanie na odpowiedź serwera (Status `201 Created` od Supabase).
5.  **Akcja 4:** Dopiero po udanym zapisie, węzeł Slacka wysyła ładnie sformatowaną wiadomość na kanał firmy.

### Flow 2: Disaster Recovery (Bezpieczeństwo)
1.  **Wyzwalacz (Trigger):** Raz na dobę (np. o północy).
2.  **Akcja:** Odpytanie lokalnego API n8n o wszystkie zapisane workflowy.
3.  **Zapis:** Zrzut struktury automatyzacji do plików JSON i bezpieczny backup na zamapowanym dysku zewnętrznym (lub bezpośrednio w Storage).

## 5. Roadmapa (Fazy Projektu)

* ✅ **Sprint 1 & 2:** Założenia projektowe, wybór technologii, wdrożenie repozytorium Git (Feature Branch Workflow).
* ✅ **Sprint 3:** Konfiguracja infrastruktury jako kod (Terraform + Oracle Cloud). Zabezpieczenie sieci i uruchomienie serwera maszynowego.
* ⏳ **Sprint 4:** Środowisko uruchomieniowe (Provisioning). Konfiguracja pamięci Swap, instalacja Dockera, powołanie do życia kontenerów n8n i połączenie z chmurowym Supabase.
* 📅 **Sprint 5:** Budowa logiki. "Wyklikanie" i zaprogramowanie połączeń (NBP -> Supabase -> Slack) oraz automatycznego backupu (DR).