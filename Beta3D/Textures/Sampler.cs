namespace Beta3D.Textures;

public abstract class Sampler : IDisposable
{
    public abstract AddressMode AddressModeU { get; }
    public abstract AddressMode AddressModeV { get; }

    public abstract FilterMode MinFilter { get; }
    public abstract FilterMode MagFilter { get; }

    public abstract int MaxAnisotropy { get; }

    public abstract double? MaxLod { get; }

    public abstract void Dispose();
}
