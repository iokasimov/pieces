module Control.Joint.Base.State where

import Control.Joint.Core (type (:.), type (:=))
import Control.Joint.Composition (Composition (Primary, unwrap))
import Control.Joint.Transformer (Transformer (Schema, lay, wrap))
import Control.Joint.Schemes.TUT (TUT (TUT))

newtype State s a = State ((->) s :. (,) s := a)

statefully :: s -> State s a -> (s, a)
statefully initial (State x) = x initial

instance Functor (State s) where
	fmap f (State x) = State $ \old -> f <$> x old

instance Applicative (State s) where
	pure x = State $ \s -> (s, x)
	State f <*> State x = State $ \old ->
		let latest = fst . x $ old in
			(latest, snd (f old) . snd . x $ old)

instance Monad (State s) where
	State x >>= f = State $ \old ->
		uncurry statefully $ f <$> x old

instance Composition (State s) where
	type Primary (State s) a = (->) s :. (,) s := a
	unwrap (State x) = x

instance Transformer (State s) where
	type Schema (State s) u = TUT ((->) s) u ((,) s)
	lay x = TUT $ \s -> (s,) <$> x
	wrap x = TUT $ pure <$> unwrap x

instance Functor u => Functor (TUT ((->) s) u ((,) s)) where
	fmap f (TUT x) = TUT $ \old -> (fmap . fmap) f $ x old

instance Monad u => Applicative (TUT ((->) s) u ((,) s)) where
	pure x = TUT $ \s -> pure (s, x)
	TUT f <*> TUT x = TUT $ \old -> f old >>= \(new, g) -> (fmap . fmap) g $ x new

instance Monad u => Monad (TUT ((->) s) u ((,) s)) where
	TUT x >>= f = TUT $ \old -> x old >>= \(new, y) -> ($ new) . unwrap . f $ y

get :: State s s
get = State $ \s -> (s, s)

modify :: (s -> s) -> State s ()
modify f = State $ \s -> (f s, ())

put :: s -> State s ()
put s = State $ \_ -> (s, ())