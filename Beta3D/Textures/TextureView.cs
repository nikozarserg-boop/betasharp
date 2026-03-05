namespace Beta3D.Textures;

public abstract class TextureView(Texture texture, int baseMipLevel, int mipLevels) : IDisposable
{
    public Texture Texture { get; } = texture;
    public int BaseMipLevel { get; } = baseMipLevel;
    public int MipLevels { get; } = mipLevels;

    public abstract bool IsDisposed { get; }

    public int GetWidth(int mipLevel) => Texture.GetWidth(mipLevel);

    public int GetHeight(int mipLevel) => Texture.GetHeight(mipLevel);

    public abstract void Dispose();
}
