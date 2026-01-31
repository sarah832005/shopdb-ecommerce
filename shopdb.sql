-- Création simple de la base de données

DROP DATABASE IF EXISTS shopdb;
CREATE DATABASE shopdb;


-- Utilisation de cette base pour tout le reste

USE shopdb;


CREATE TABLE compte (
  id_compte    INT AUTO_INCREMENT PRIMARY KEY,
  nom          VARCHAR(120) NOT NULL,
  prenom       VARCHAR(120) NOT NULL,
  email        VARCHAR(180) NOT NULL UNIQUE,
  mot_de_passe VARCHAR(255) NOT NULL,
  telephone    VARCHAR(30),
  role         VARCHAR(50) NOT NULL,        
  est_actif    BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE admin (
  id_admin   INT AUTO_INCREMENT PRIMARY KEY,
  id_compte  INT NOT NULL UNIQUE,
  FOREIGN KEY (id_compte) REFERENCES compte(id_compte)
) ENGINE=InnoDB;

CREATE TABLE analyste (
  id_analyste INT AUTO_INCREMENT PRIMARY KEY,
  id_compte   INT NOT NULL UNIQUE,
  FOREIGN KEY (id_compte) REFERENCES compte(id_compte)
) ENGINE=InnoDB;

CREATE TABLE financier (
  id_financier  INT AUTO_INCREMENT PRIMARY KEY,
  email_pro     VARCHAR(180),
  telephone_pro VARCHAR(30),
  id_compte     INT NOT NULL UNIQUE,
  FOREIGN KEY (id_compte) REFERENCES compte(id_compte)
) ENGINE=InnoDB;

CREATE TABLE gestionnaire_de_stock (
  id_gestionnaire INT AUTO_INCREMENT PRIMARY KEY,
  id_compte       INT NOT NULL UNIQUE,
  FOREIGN KEY (id_compte) REFERENCES compte(id_compte)
) ENGINE=InnoDB;

CREATE TABLE vendeur (
  id_vendeur INT AUTO_INCREMENT PRIMARY KEY,
  id_compte  INT NOT NULL UNIQUE,
  FOREIGN KEY (id_compte) REFERENCES compte(id_compte)
) ENGINE=InnoDB;

CREATE TABLE fournisseur (
  id_fournisseur INT AUTO_INCREMENT PRIMARY KEY,
  id_compte      INT NOT NULL UNIQUE,
  FOREIGN KEY (id_compte) REFERENCES compte(id_compte)
) ENGINE=InnoDB;

CREATE TABLE livreur (
  id_livreur INT AUTO_INCREMENT PRIMARY KEY,
  id_compte  INT NOT NULL UNIQUE,
  FOREIGN KEY (id_compte) REFERENCES compte(id_compte)
) ENGINE=InnoDB;

CREATE TABLE client (
  id_client INT AUTO_INCREMENT PRIMARY KEY,
  id_compte INT NOT NULL UNIQUE,
  FOREIGN KEY (id_compte) REFERENCES compte(id_compte)
) ENGINE=InnoDB;


-- 2) REFERENTIELS & CATALOGUE


-- Catégorie
CREATE TABLE categorie (
  id_categorie        INT AUTO_INCREMENT PRIMARY KEY,
  datecreation        DATETIME DEFAULT CURRENT_TIMESTAMP,
  id_categorie_parent INT NULL,
  FOREIGN KEY (id_categorie_parent) REFERENCES categorie(id_categorie)
) ENGINE=InnoDB;

CREATE TABLE catalogue (
  id_catalogue INT AUTO_INCREMENT PRIMARY KEY,
  date_creation DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


CREATE TABLE produit (
  id_produit   INT AUTO_INCREMENT PRIMARY KEY,
  nom          VARCHAR(180) NOT NULL,
  description  TEXT,
  prix_ht      DECIMAL(10,2) NOT NULL,
  statut       BOOLEAN NOT NULL DEFAULT TRUE,
  id_vendeur   INT NOT NULL,
  FOREIGN KEY (id_vendeur) REFERENCES vendeur(id_vendeur)
) ENGINE=InnoDB;

CREATE TABLE image_produit (
  id_image   INT AUTO_INCREMENT PRIMARY KEY,
  id_produit INT NOT NULL,
  url_image  VARCHAR(800) NOT NULL,
  FOREIGN KEY (id_produit) REFERENCES produit(id_produit) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE catalogue_produit (
  id_catalogue INT NOT NULL,
  id_produit   INT NOT NULL,
  PRIMARY KEY (id_catalogue, id_produit),
  FOREIGN KEY (id_catalogue) REFERENCES catalogue(id_catalogue) ON DELETE CASCADE,
  FOREIGN KEY (id_produit)   REFERENCES produit(id_produit)   ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================
-- 3) STOCK
-- =========================
CREATE TABLE stock (
  id_produit            INT PRIMARY KEY,               
  quantite_disponibles  INT NOT NULL DEFAULT 0,
  seuil_alerte          INT NOT NULL DEFAULT 0,
  FOREIGN KEY (id_produit) REFERENCES produit(id_produit) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================
-- 4) PANIER
-- =========================
CREATE TABLE panier (
  id_panier      INT AUTO_INCREMENT PRIMARY KEY,
  id_client      INT NOT NULL,
  date_creation  DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_client) REFERENCES client(id_client) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE ligne_panier (
  id_ligne_panier INT AUTO_INCREMENT PRIMARY KEY,
  id_panier       INT NOT NULL,
  id_produit      INT NOT NULL,
  quantite        INT NOT NULL,
  FOREIGN KEY (id_panier)  REFERENCES panier(id_panier)  ON DELETE CASCADE,
  FOREIGN KEY (id_produit) REFERENCES produit(id_produit)
) ENGINE=InnoDB;

-- =========================
-- 5) ADRESSES & AVIS
-- =========================
CREATE TABLE adresses (
  id_adresse          INT AUTO_INCREMENT PRIMARY KEY,
  rue                 VARCHAR(180) NOT NULL,
  ville               VARCHAR(120) NOT NULL,
  pays                VARCHAR(120) NOT NULL,
  adresse_livraison   BOOLEAN NOT NULL DEFAULT FALSE,
  adresse_facturation BOOLEAN NOT NULL DEFAULT FALSE,
  id_client           INT NOT NULL,
  FOREIGN KEY (id_client) REFERENCES client(id_client)
) ENGINE=InnoDB;

CREATE TABLE avis (
  id_avis    INT AUTO_INCREMENT PRIMARY KEY,
  note       TINYINT NOT NULL,
  commentaire TEXT,
  date_avis  DATETIME DEFAULT CURRENT_TIMESTAMP,
  id_client  INT NOT NULL,
  id_produit INT NOT NULL,
  FOREIGN KEY (id_client)  REFERENCES client(id_client),
  FOREIGN KEY (id_produit) REFERENCES produit(id_produit)
) ENGINE=InnoDB;

-- =========================
-- 6) COMMANDES & COUPONS
-- =========================
CREATE TABLE commande (
  id_commande      INT AUTO_INCREMENT PRIMARY KEY,
  date_commande    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  statut_commande  VARCHAR(30) NOT NULL,          -- comme dans le diagramme
  total_ht         DECIMAL(12,2) NOT NULL DEFAULT 0,
  total_tva        DECIMAL(12,2) NOT NULL DEFAULT 0,
  total_ttc        DECIMAL(12,2) NOT NULL DEFAULT 0,
  id_client        INT NOT NULL,
  id_adressfact    INT NOT NULL,
  id_adresselivr   INT NOT NULL,
  id_panier        INT NULL,                       -- vu sur le diagramme
  FOREIGN KEY (id_client)      REFERENCES client(id_client),
  FOREIGN KEY (id_adressfact)  REFERENCES adresses(id_adresse),
  FOREIGN KEY (id_adresselivr) REFERENCES adresses(id_adresse),
  FOREIGN KEY (id_panier)      REFERENCES panier(id_panier)
) ENGINE=InnoDB;

CREATE TABLE ligne_commande (
  id_ligne_commande INT AUTO_INCREMENT PRIMARY KEY,
  id_commande       INT NOT NULL,
  id_produit        INT NOT NULL,
  quantite          INT NOT NULL,
  prix_unitaire     DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (id_commande) REFERENCES commande(id_commande) ON DELETE CASCADE,
  FOREIGN KEY (id_produit)  REFERENCES produit(id_produit)
) ENGINE=InnoDB;

CREATE TABLE coupons (
  id_coupon      INT AUTO_INCREMENT PRIMARY KEY,
  code_coupon    VARCHAR(60) NOT NULL UNIQUE,
  date_expiration DATE,
  valeur         DECIMAL(10,2) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE commande_coupon (
  id_commande INT NOT NULL,
  id_coupon   INT NOT NULL,
  PRIMARY KEY (id_commande, id_coupon),
  FOREIGN KEY (id_commande) REFERENCES commande(id_commande) ON DELETE CASCADE,
  FOREIGN KEY (id_coupon)   REFERENCES coupons(id_coupon)   ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================
-- 7) PAIEMENT → FACTURE (lien direct)
-- =========================
CREATE TABLE mode_paiement (
  id_mode_paiement  INT AUTO_INCREMENT PRIMARY KEY,
  libelle           VARCHAR(80) NOT NULL,
  actif             BOOLEAN NOT NULL DEFAULT TRUE,
  frais_fix         DECIMAL(10,2) DEFAULT 0,
  frais_pourcentage DECIMAL(5,2)  DEFAULT 0
) ENGINE=InnoDB;
CREATE TABLE paiement (
  id_paiement      INT AUTO_INCREMENT PRIMARY KEY,
  id_commande      INT NOT NULL,
  id_mode_paiement INT NOT NULL,          -- <- la FK est ici
  montant          DECIMAL(12,2) NOT NULL,
  devise           VARCHAR(10)   NOT NULL,
  date_paiement    DATETIME DEFAULT CURRENT_TIMESTAMP,
  statut_paiement  VARCHAR(20) NOT NULL,
  code_autorisation VARCHAR(120),
  commentaire       VARCHAR(255),
  id_financier      INT,
  FOREIGN KEY (id_commande)      REFERENCES commande(id_commande),
  FOREIGN KEY (id_mode_paiement) REFERENCES mode_paiement(id_mode_paiement),
  FOREIGN KEY (id_financier)     REFERENCES financier(id_financier)
) ENGINE=InnoDB;

CREATE TABLE facture (
  id_facture     INT AUTO_INCREMENT PRIMARY KEY,
  numero_facture VARCHAR(60) NOT NULL UNIQUE,
  date_emission  DATETIME DEFAULT CURRENT_TIMESTAMP,
  montant_ht     DECIMAL(12,2) NOT NULL,
  montant_tva    DECIMAL(12,2) NOT NULL,
  montant_ttc    DECIMAL(12,2) NOT NULL,
  statut_facture VARCHAR(20) NOT NULL,
  id_paiement    INT NOT NULL UNIQUE,
  FOREIGN KEY (id_paiement) REFERENCES paiement(id_paiement)
) ENGINE=InnoDB;
-- =========================
-- 8) LIVRAISONS
-- =========================
CREATE TABLE livraison (
  id_livraison     INT AUTO_INCREMENT PRIMARY KEY,
  date_livraison   DATETIME,
  statut_livraison VARCHAR(30),
  id_commande      INT NOT NULL,
  id_livreur       INT,
  FOREIGN KEY (id_commande) REFERENCES commande(id_commande) ON DELETE CASCADE,
  FOREIGN KEY (id_livreur)  REFERENCES livreur(id_livreur)
) ENGINE=InnoDB;

CREATE TABLE ligne_de_livraison (
  id_ligne_livraison INT AUTO_INCREMENT PRIMARY KEY,
  id_produit         INT NOT NULL,
  id_livraison       INT NOT NULL,
  quantite_livree    INT NOT NULL,
  FOREIGN KEY (id_produit)  REFERENCES produit(id_produit),
  FOREIGN KEY (id_livraison) REFERENCES livraison(id_livraison) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================
-- 9) DEMANDES (fournisseur ↔ gestionnaire ↔ produit)
-- =========================
CREATE TABLE demandes (
  id_demande     INT AUTO_INCREMENT PRIMARY KEY,
  date_demande   DATETIME DEFAULT CURRENT_TIMESTAMP,
  statut_demande VARCHAR(30),
  id_gestionnaire INT NOT NULL,
  id_fournisseur  INT NOT NULL,
  id_produit      INT NOT NULL,
  FOREIGN KEY (id_gestionnaire) REFERENCES gestionnaire_de_stock(id_gestionnaire),
  FOREIGN KEY (id_fournisseur)  REFERENCES fournisseur(id_fournisseur),
  FOREIGN KEY (id_produit)      REFERENCES produit(id_produit)
) ENGINE=InnoDB;

-- =========================
-- 10) INDEX 
-- =========================
CREATE INDEX idx_compte_email        ON compte(email);
CREATE INDEX idx_prod_nom            ON produit(nom);
CREATE INDEX idx_cmd_client_date     ON commande(id_client, date_commande);
CREATE INDEX idx_ligne_cmd_commande  ON ligne_commande(id_commande);
CREATE INDEX idx_pay_cmd             ON paiement(id_commande);
CREATE INDEX idx_liv_cmd             ON livraison(id_commande);

USE shopdb;

-- 1) Statistiques de ventes (par jour)
CREATE OR REPLACE VIEW v_stats_ventes AS
SELECT
  DATE(date_commande) AS jour,
  COUNT(*)            AS nb_commandes,
  SUM(total_ttc)      AS ca_ttc
FROM commande
GROUP BY DATE(date_commande);

-- 2) Comportement client (indicateurs basiques)
CREATE OR REPLACE VIEW v_comportement_client AS
SELECT
  c.id_client,
  COUNT(co.id_commande) AS nb_commandes,
  MAX(co.date_commande) AS derniere_commande,
  SUM(co.total_ttc)     AS total_ttc
FROM client c
LEFT JOIN commande co ON co.id_client = c.id_client
GROUP BY c.id_client;

-- 3) Performance produits (quantité vendue et CA HT)
CREATE OR REPLACE VIEW v_performance_produits AS
SELECT
  p.id_produit,
  p.nom,
  SUM(lc.quantite)                         AS qte_vendue,
  SUM(lc.quantite * lc.prix_unitaire)      AS ca_ht
FROM produit p
LEFT JOIN ligne_commande lc ON lc.id_produit = p.id_produit
GROUP BY p.id_produit, p.nom;

-- 4) Rapports financiers (par jour de paiement)
CREATE OR REPLACE VIEW v_rapports_financiers AS
SELECT
  DATE(p.date_paiement) AS jour,
  COUNT(*)              AS nb_paiements,
  SUM(p.montant)        AS montant_total
FROM paiement p
GROUP BY DATE(p.date_paiement);

-- 5) Historique commande (timeline simple)
CREATE OR REPLACE VIEW v_historique_commande AS
SELECT
  c.id_commande,
  c.date_commande,
  c.statut_commande,
  c.total_ttc,
  MIN(p.date_paiement)  AS date_paiement,
  MIN(l.date_livraison) AS date_livraison
FROM commande c
LEFT JOIN paiement  p ON p.id_commande = c.id_commande
LEFT JOIN livraison l ON l.id_commande = c.id_commande
GROUP BY c.id_commande, c.date_commande, c.statut_commande, c.total_ttc;


DELIMITER $$

CREATE OR REPLACE PROCEDURE sp_ajouter_ligne_commande(
  IN p_id_commande INT,
  IN p_id_produit  INT,
  IN p_quantite    INT
)
BEGIN
  DECLARE v_prix DECIMAL(10,2);

  -- Récupère le prix courant du produit
  SELECT prix_ht INTO v_prix
  FROM produit
  WHERE id_produit = p_id_produit;

  -- Insère la ligne (prix fixé ici)
  INSERT INTO ligne_commande(id_commande, id_produit, quantite, prix_unitaire)
  VALUES (p_id_commande, p_id_produit, p_quantite, v_prix);
END$$

DELIMITER ;

DELIMITER $$

CREATE OR REPLACE TRIGGER trg_stock_after_insert_ligne
AFTER INSERT ON ligne_commande
FOR EACH ROW
BEGIN
  UPDATE stock
  SET quantite_disponibles = quantite_disponibles - NEW.quantite
  WHERE id_produit = NEW.id_produit;
END$$

DELIMITER ;



DELIMITER $$

DROP TRIGGER IF EXISTS trg_produit_statut_by_stock $$
CREATE TRIGGER trg_produit_statut_by_stock
AFTER UPDATE ON stock
FOR EACH ROW
BEGIN
  IF NEW.quantite_disponibles <= NEW.seuil_alerte THEN
    UPDATE produit
    SET statut = 0
    WHERE id_produit = NEW.id_produit;
  ELSE
    UPDATE produit
    SET statut = 1
    WHERE id_produit = NEW.id_produit;
  END IF;
END$$

DELIMITER ;
