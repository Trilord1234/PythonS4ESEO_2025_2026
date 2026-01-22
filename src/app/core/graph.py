"""
Module core.graph
-----------------
Implémentation d'un graphe non orienté basé sur une liste d'adjacence.

Ce module doit être TOTALEMENT indépendant de l'UI.
Tous les tests du palier A doivent passer avec ce fichier.
"""

from typing import Any


class Graph:
    """
    Représente un graphe non orienté.
    
    Structure de données : liste d'adjacence (dictionnaire)
    - Clé : nom du nœud (str)
    - Valeur : liste des voisins (list[str])
    
    Exemple d'usage:
        >>> g = Graph()
        >>> g.add_node("A")
        >>> g.add_node("B")
        >>> g.add_edge("A", "B")
        >>> g.neighbors("A")
        ['B']
    """
    
    def __init__(self):
        """Initialise un graphe vide."""    
        self.graph = {}
    
    def add_node(self, node: str) -> None:
        """
        Ajoute un nœud au graphe.
        
        Si le nœud existe déjà, ne fait rien (pas d'erreur).
        
        Args:
            node: Identifiant unique du nœud (chaîne de caractères)
        
        Raises:
            TypeError: Si node n'est pas une chaîne de caractères
        
        Exemple:
            >>> g = Graph()
            >>> g.add_node("Paris")
            >>> g.has_node("Paris")
            True
        """
        if not isinstance(node, str):
            raise TypeError("Erreur, le noeud doit être une chaine de caractère.")
        if not self.has_node(node):
            self.graph[node] = []
    
    def add_edge(self, a: str, b: str) -> None:
        """
        Ajoute une arête non orientée entre deux nœuds.
        
        Si l'arête existe déjà, ne fait rien.
        Si l'un des nœuds n'existe pas, il est créé automatiquement.
        
        Args:
            a: Premier nœud
            b: Deuxième nœud
        
        Exemple:
            >>> g = Graph()
            >>> g.add_edge("Paris", "Lyon")
            >>> g.has_edge("Paris", "Lyon")
            True
            >>> g.has_edge("Lyon", "Paris")  # Non orienté !
            True
        """
        
        if not isinstance(a, str) and isinstance(b, str):
            raise TypeError("Erreur, les deux noeuds doive être une chaine de caractère")
        self.add_node(a)
        self.add_node(b)
        if not self.has_edge(a,b):
            self.graph[a].append(b)
            self.graph[b].append(a)
        else :
            raise ValueError("Le node a ou b n'existe pas")
    
    def remove_node(self, node: str) -> None:
        """
        Supprime un nœud et toutes ses arêtes associées.
        
        Args:
            node: Nœud à supprimer
        
        Raises:
            ValueError: Si le nœud n'existe pas
        """
        if not isinstance(node, str):
            raise ValueError("Ton noeud doit être un str")
        if node not in self.graph:
            raise ValueError(f"le noeud {node} n'existe pas")
        self.graph.pop(node)
        for key in self.graph:
            if node in self.graph[key]:
                self.graph[key].remove(node)
    
    def remove_edge(self, a: str, b: str) -> None:
        """
        Supprime une arête entre deux nœuds.
        
        Args:
            a: Premier nœud
            b: Deuxième nœud
        
        Raises:
            ValueError: Si l'arête n'existe pas
        """
        if a in self.graph and b in self.graph:
            if b in self.graph[a] and a in self.graph[b]:
                self.graph[a].remove(b)
                self.graph[b].remove(a)
            else :
                raise ValueError("Le noeud n'existe pas")
    
    def neighbors(self, node: str) -> list[str]:
        """
        Retourne la liste des voisins d'un nœud.
        
        Args:
            node: Nœud dont on veut les voisins
        
        Returns:
            Liste triée des nœuds voisins (ordre alphabétique)
        
        Raises:
            ValueError: Si le nœud n'existe pas
        
        Note:
            ⚠️ CRITIQUE : Cette méthode DOIT retourner une liste TRIÉE !
            Les algorithmes DFS et BFS en dépendent pour être déterministes.
            Les tests vérifieront explicitement cet ordre alphabétique.
        
        Exemple:
            >>> g = Graph()
            >>> g.add_edge("A", "Z")
            >>> g.add_edge("A", "B")
            >>> g.add_edge("A", "M")
            >>> g.neighbors("A")
            ['B', 'M', 'Z']  # Toujours en ordre alphabétique
        """
        if not self.has_node(node):
            raise ValueError(f"le noeud : {node} n'existe pas")
        copains = self.graph[node]
        return sorted(copains)
    
    def has_node(self, node: str) -> bool:
        """Vérifie si un nœud existe dans le graphe."""
        return node in self.graph
    
    def has_edge(self, a: str, b: str) -> bool:
        """Vérifie si une arête existe entre deux nœuds."""
        if a not in self.graph or b not in self.graph:
            return False
        return b in self.graph[a]
    
    def nodes(self) -> list[str]:
        """
        Retourne la liste de tous les nœuds du graphe.
        
        Returns:
            Liste triée des nœuds (ordre alphabétique)
        """
        return sorted(self.graph.keys())

    def edges(self) -> list[tuple[str, str]]:
        """
        Retourne la liste de toutes les arêtes du graphe.
        
        Returns:
            Liste de tuples (a, b) où a < b (ordre alphabétique)
            Chaque arête n'apparaît qu'une seule fois.
        
        Exemple:
            >>> g = Graph()
            >>> g.add_edge("B", "A")
            >>> g.edges()
            [('A', 'B')]  # Ordre normalisé
        """
        result = set()
        for node, voisin in self.graph.items():
            for copain in voisin :
                if node < copain:
                    edge = (copain, node)
                    result.add(edge)
        return sorted(list(result))
    
    def __len__(self) -> int:
        """Retourne le nombre de nœuds dans le graphe."""
        return len(self.graph)
    
    def __repr__(self) -> str:
        """Représentation lisible du graphe pour debug."""
        return f"Graph(nodes={len(self)}, edges={len(self.edges())})"
