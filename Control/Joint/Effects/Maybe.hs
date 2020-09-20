module Control.Joint.Effects.Maybe where

import Control.Joint.Operators ((<$$>), (<**>))
import Control.Joint.Abilities.Completable (Completable (complete))
import Control.Joint.Abilities.Interpreted (Interpreted (Primary, run))
import Control.Joint.Abilities.Transformer (Transformer (embed, build, unite), Schema, (:>) (T))
import Control.Joint.Abilities.Adaptable (Adaptable (adapt))
import Control.Joint.Schemes (UT (UT))

instance Interpreted Maybe where
	type Primary Maybe a = Maybe a
	run x = x

type instance Schema Maybe = UT Maybe

instance Transformer Maybe where
	embed x = T . UT $ Just <$> x
	build x = T . UT . pure $ x
	unite = T . UT

instance Functor u => Functor (UT Maybe u) where
	fmap f (UT x) = UT $ f <$$> x

instance Applicative u => Applicative (UT Maybe u) where
	pure = UT . pure . pure
	UT f <*> UT x = UT $ f <**> x

instance (Applicative u, Monad u) => Monad (UT Maybe u) where
	UT x >>= f = UT $ x >>= maybe (pure Nothing) (run . f)

instance Completable (Either e) Maybe where
	complete = either (const Nothing) Just

type Optional = Adaptable Maybe

nothing :: Optional t => t a
nothing = adapt Nothing
